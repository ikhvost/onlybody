import Foundation
import Observation

@MainActor
@Observable
final class SessionBuilderViewModel {
    private let workoutsRepository: any WorkoutRepository
    private let exercisesRepository: any ExerciseRepository
    private let smartGenerator: SmartWorkoutGenerator
    private let onScheduleChanged: @MainActor () async -> Void

    private var isPopulating = false
    private var generatedConfiguration: SmartWorkoutConfiguration?
    private var initialDraft: BuilderDraft?
    var hasUnsavedChanges: Bool { initialDraft != draft }

    private var draft: BuilderDraft {
        BuilderDraft(name: name, mode: mode, targets: Set(targetMuscleGroups),
                     movements: movements, durationMinutes: durationMinutes, restSeconds: restSeconds, days: Set(scheduledDays))
    }

    private let requestedWorkoutID: UUID?
    private(set) var editingWorkout: WorkoutSnapshot?

    var numberInputs: [String: String] = [:]
    var numberErrors: Set<String> = []
    var hasInvalidNumbers: Bool { !numberErrors.isEmpty }
    var name: String = ""
    var mode: WorkoutMode = .smart { didSet { refreshSmartMovements() } }
    var targetMuscleGroups: [String] = [] { didSet { refreshSmartMovements() } }
    var movements: [MovementConfig] = []
    var scheduledDays: [String] = []
    private(set) var durationMinutes = 30
    private(set) var restSeconds = 45
    var hasMixedRest: Bool { movements.contains { $0.restSeconds != restSeconds } }
    private(set) var isLoading = false
    var isSaving = false
    var errorMessage: String?
    var allExercises: [ExerciseSnapshot] = []

    let dayNames = Weekdays.shortNames

    var isEditMode: Bool {
        editingWorkout != nil || requestedWorkoutID != nil
    }

    var estimatedDurationSeconds: Int {
        let estimator = WorkoutDurationEstimator()
        return movements.reduce(0) { total, movement in
            estimator.adding(estimator.seconds(sets: movement.sets, reps: movement.reps, restSeconds: movement.restSeconds), to: total)
        }
    }

    var estimatedDurationMinutes: Int {
        max(1, Int(ceil(Double(estimatedDurationSeconds) / 60.0)))
    }

    init(
        workouts: any WorkoutRepository,
        exercises: any ExerciseRepository,
        workout: WorkoutSnapshot? = nil,
        targetMuscleGroups: [String] = [],
        workoutID: UUID? = nil,
        generator: SmartWorkoutGenerator = SmartWorkoutGenerator(),
        onScheduleChanged: @escaping @MainActor () async -> Void = {}
    ) {
        self.requestedWorkoutID = workoutID
        self.workoutsRepository = workouts
        self.exercisesRepository = exercises
        self.smartGenerator = generator
        self.onScheduleChanged = onScheduleChanged
        self.editingWorkout = workout
        self.targetMuscleGroups = targetMuscleGroups

        if let workout {
            populateFrom(workout)
        } else if !targetMuscleGroups.isEmpty {
            mode = .smart
        } else {
            mode = .manual
        }
        initialDraft = draft
        if editingWorkout != nil {
            generatedConfiguration = SmartWorkoutConfiguration(targetMuscleGroups: self.targetMuscleGroups,
                                                                durationMinutes: durationMinutes, restSeconds: restSeconds)
        }
    }

    func loadExercises() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            allExercises = try await exercisesRepository.allExercises()
            if let requestedWorkoutID, editingWorkout == nil {
                guard let saved = try await workoutsRepository.workout(by: requestedWorkoutID) else {
                    errorMessage = String(localized: .uiWorkoutNotFound)
                    return
                }
                editingWorkout = saved
                populateFrom(saved)
                initialDraft = draft
                generatedConfiguration = SmartWorkoutConfiguration(targetMuscleGroups: targetMuscleGroups,
                                                                    durationMinutes: durationMinutes, restSeconds: restSeconds)
            }
            refreshSmartMovements()
        } catch {
            errorMessage = String(localized: .uiCouldNotLoadExercises)
        }
    }

    func addMovement(_ exercise: ExerciseSnapshot) {
        let config = MovementConfig(exercise: exercise, restSeconds: restSeconds)
        movements.append(config)
    }

    func setDurationMinutes(_ value: Int) {
        guard mode == .smart, WorkoutTimingOptions.durations.contains(value) else { return }
        durationMinutes = value
        refreshSmartMovements()
    }

    func setDefaultRestSeconds(_ value: Int) {
        guard WorkoutTimingOptions.rests.contains(value) else { return }
        restSeconds = value
        for index in movements.indices { movements[index].restSeconds = value }
        numberInputs = numberInputs.filter { !$0.key.hasSuffix(".Rest") }
        numberErrors = numberErrors.filter { !$0.hasSuffix(".Rest") }
        refreshSmartMovements()
    }

    func removeMovement(_ id: UUID) {
        movements.removeAll { $0.id == id }
        numberInputs = numberInputs.filter { !$0.key.hasPrefix(id.uuidString) }
        numberErrors = numberErrors.filter { !$0.hasPrefix(id.uuidString) }
    }

    func moveMovement(_ id: UUID, to targetID: UUID) {
        guard !isSaving, !hasInvalidNumbers, let from = movements.firstIndex(where: { $0.id == id }),
              let to = movements.firstIndex(where: { $0.id == targetID }), from != to else { return }
        movements.insert(movements.remove(at: from), at: to)
    }

    func replaceMovement(_ id: UUID, with exercise: ExerciseSnapshot) {
        guard !isSaving, !hasInvalidNumbers, let index = movements.firstIndex(where: { $0.id == id }) else { return }
        movements[index].exercise = exercise
    }

    func setSets(_ value: Int, forMovement id: UUID) {
        guard let index = movements.firstIndex(where: { $0.id == id }) else { return }
        movements[index].sets = max(1, value)
    }

    func setReps(_ value: Int, forMovement id: UUID) {
        guard let index = movements.firstIndex(where: { $0.id == id }) else { return }
        movements[index].reps = max(1, value)
    }

    func setRest(_ value: Int, forMovement id: UUID) {
        guard let index = movements.firstIndex(where: { $0.id == id }) else { return }
        movements[index].restSeconds = max(15, value)
    }

    func numberText(_ field: String, movement: MovementConfig) -> String {
        let value = field == "Sets" ? movement.sets : field == "Reps" ? movement.reps : movement.restSeconds
        return numberInputs["\(movement.id).\(field)"] ?? String(value)
    }

    func numberHasError(_ field: String, id: UUID) -> Bool { numberErrors.contains("\(id).\(field)") }

    func enterNumber(_ text: String, field: String, id: UUID) {
        let key = "\(id).\(field)"
        numberInputs[key] = text
        guard let value = WorkoutNumberParser().integer(text, minimum: field == "Rest" ? 15 : 1) else {
            numberErrors.insert(key)
            return
        }
        numberErrors.remove(key)
        switch field {
        case "Sets": setSets(value, forMovement: id)
        case "Reps": setReps(value, forMovement: id)
        default: setRest(value, forMovement: id)
        }
    }

    func stepNumber(_ field: String, id: UUID, increasing: Bool) {
        guard let movement = movements.first(where: { $0.id == id }) else { return }
        let value = field == "Sets" ? movement.sets : field == "Reps" ? movement.reps : movement.restSeconds
        let step = field == "Rest" ? 15 : 1
        let next = max(field == "Rest" ? 15 : 1, min(Int(Int32.max), value + (increasing ? step : -step)))
        enterNumber(String(next), field: field, id: id)
    }

    func toggleDay(_ day: String) {
        if let index = scheduledDays.firstIndex(of: day) {
            scheduledDays.remove(at: index)
        } else {
            scheduledDays.append(day)
        }
    }

    func deleteWorkout() async -> Bool {
        guard let editingWorkout, !isSaving else { return false }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            try await workoutsRepository.delete(by: editingWorkout.id)
            await onScheduleChanged()
            return true
        } catch {
            errorMessage = String(localized: .uiCouldNotDeleteWorkoutYourTrainingHistoryIsUnchanged)
            return false
        }
    }

    func save() async -> Bool {
        guard !isLoading, !isSaving, !hasInvalidNumbers, requestedWorkoutID == nil || editingWorkout != nil else { return false }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            if mode == .smart && targetMuscleGroups.isEmpty {
                mode = .manual
            }

            refreshSmartMovements()
            applySmartTimeBudget()
            if mode == .smart && movements.isEmpty {
                errorMessage = String(localized: .uiNoExercisesMatchTryDifferentMuscleGroups)
                return false
            }

            var workout: WorkoutSnapshot
            if let existing = editingWorkout {
                workout = existing
            } else {
                workout = WorkoutSnapshot()
            }

            workout.name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? String(localized: .uiMySession)
                : name.trimmingCharacters(in: .whitespacesAndNewlines)
            workout.mode = mode.rawValue
            workout.durationMinutes = mode == .smart ? durationMinutes : nil
            workout.restSeconds = restSeconds
            workout.scheduledDays = scheduledDays
            workout.targetMuscleGroups = targetMuscleGroups

            var newItems: [WorkoutItemSnapshot] = []
            for (index, movement) in movements.enumerated() {
                var item = WorkoutItemSnapshot()
                item.id = movement.id
                item.order = index
                item.sets = movement.sets
                item.targetReps = movement.reps
                item.restSeconds = movement.restSeconds
                item.exercise = movement.exercise
                newItems.append(item)
            }
            workout.items = newItems

            try await workoutsRepository.save(workout)
            initialDraft = draft
            await onScheduleChanged()
            return true
        } catch {
            errorMessage = String(localized: .uiCouldNotSaveSession)
            return false
        }
    }

    func refreshSmartMovements() {
        guard !isPopulating, mode == .smart, !targetMuscleGroups.isEmpty, !allExercises.isEmpty else { return }
        let config = SmartWorkoutConfiguration(targetMuscleGroups: targetMuscleGroups,
                                               durationMinutes: durationMinutes, restSeconds: restSeconds)
        guard generatedConfiguration != config || movements.isEmpty else {
            applySmartTimeBudget()
            return
        }
        movements = smartGenerator.generate(config: config, from: allExercises).map {
            MovementConfig(exercise: $0.exercise, sets: $0.sets, reps: $0.reps, restSeconds: $0.restSeconds)
        }
        generatedConfiguration = config
        numberInputs = [:]
        numberErrors = []
    }

    /// Keeps complete exercises, preserving their IDs and edited parameters within the budget.
    func applySmartTimeBudget() {
        guard mode == .smart else { return }
        let estimator = WorkoutDurationEstimator()
        let budget = estimator.budget(minutes: durationMinutes)
        var total = 0
        movements = movements.filter { movement in
            let seconds = estimator.seconds(sets: movement.sets, reps: movement.reps, restSeconds: movement.restSeconds)
            guard seconds <= budget - total else { return false }
            total += seconds
            return true
        }
        let remaining = Set(movements.map { $0.id.uuidString })
        numberInputs = numberInputs.filter { remaining.contains(String($0.key.prefix(36))) }
        numberErrors = numberErrors.filter { remaining.contains(String($0.prefix(36))) }
    }

    private func populateFrom(_ workout: WorkoutSnapshot) {
        isPopulating = true
        defer { isPopulating = false }
        name = workout.name
        mode = WorkoutMode(rawValue: workout.mode) ?? .manual
        targetMuscleGroups = workout.targetMuscleGroups
        scheduledDays = workout.scheduledDays
        durationMinutes = workout.durationMinutes ?? 30
        let savedRests = Set(workout.items.map(\.restSeconds))
        restSeconds = workout.restSeconds ?? (savedRests.count == 1 ? savedRests.first ?? 45 : 45)

        movements = workout.items.sorted { $0.order < $1.order }.compactMap { item in
            guard let exercise = item.exercise else { return nil }
            return MovementConfig(
                id: item.id,
                exercise: exercise,
                sets: item.sets,
                reps: item.targetReps,
                restSeconds: item.restSeconds
            )
        }
    }
}
