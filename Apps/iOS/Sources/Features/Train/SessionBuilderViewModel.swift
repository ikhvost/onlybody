import Foundation
import Observation

@MainActor
@Observable
final class SessionBuilderViewModel {
    private let workoutsRepository: any WorkoutRepository
    private let exercisesRepository: any ExerciseRepository
    private let smartGenerator: SmartWorkoutGenerator
    private let onScheduleChanged: @MainActor () async -> Void

    private var smartContext: SmartEditorContext?
    var isDailySmart: Bool { smartContext != nil }
    var canSave: Bool {
        !isLoading && !isSaving && !hasInvalidNumbers && (!isDailySmart || !movements.isEmpty) && movements.allSatisfy {
            (1...Int(Int32.max)).contains($0.sets) && (1...Int(Int32.max)).contains($0.reps)
                && (0...Int(Int32.max)).contains($0.restSeconds)
        }
    }
    var minimumRest: Int { isDailySmart ? 0 : 15 }
    private(set) var savedWorkout: WorkoutSnapshot?
    private var isPopulating = false
    private var generatedConfiguration: SmartWorkoutConfiguration?
    private var initialDraft: BuilderDraft?
    var hasUnsavedChanges: Bool { initialDraft != draft || smartContext?.requiresSave == true }

    private var draft: BuilderDraft {
        BuilderDraft(name: name, mode: mode, targets: Set(targetMuscleGroups),
                     movements: movements, durationMinutes: durationMinutes, restSeconds: restSeconds, days: Set(scheduledDays))
    }

    private let requestedWorkoutID: UUID?
    private(set) var editingWorkout: WorkoutSnapshot?

    var numberInputs: [String: String] = [:]
    var numberErrors: Set<String> = []
    private var originalEditingReps: [UUID: Int] = [:]
    var hasInvalidNumbers: Bool { !numberErrors.isEmpty }
    var name: String = ""
    private(set) var mode: WorkoutMode = .manual
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
        smartContext?.isExisting ?? (editingWorkout != nil || requestedWorkoutID != nil)
    }

    var estimatedDurationSeconds: Int {
        if isDailySmart { return SmartPrescription().seconds(workoutItems) }
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
        smartContext: SmartEditorContext? = nil,
        onScheduleChanged: @escaping @MainActor () async -> Void = {}
    ) {
        self.requestedWorkoutID = workoutID
        self.workoutsRepository = workouts
        self.exercisesRepository = exercises
        self.smartGenerator = generator
        self.onScheduleChanged = onScheduleChanged
        self.smartContext = smartContext
        self.editingWorkout = smartContext?.workout ?? workout
        self.targetMuscleGroups = targetMuscleGroups

        if let workout = smartContext?.workout ?? workout {
            populateFrom(workout)
        } else if !targetMuscleGroups.isEmpty {
            mode = .smart
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
        guard !isDailySmart, mode == .smart, WorkoutTimingOptions.durations.contains(value) else { return }
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
        originalEditingReps.removeValue(forKey: id)
        movements.removeAll { $0.id == id }
        numberInputs = numberInputs.filter { !$0.key.hasPrefix(id.uuidString) }
        numberErrors = numberErrors.filter { !$0.hasPrefix(id.uuidString) }
    }

    /// Cancelling a movement sheet discards its numeric edits, including invalid input.
    func restoreMovement(_ original: MovementConfig) {
        originalEditingReps.removeValue(forKey: original.id)
        guard let index = movements.firstIndex(where: { $0.id == original.id }) else { return }
        movements[index] = original
        numberInputs = numberInputs.filter { !$0.key.hasPrefix(original.id.uuidString) }
        numberErrors = numberErrors.filter { !$0.hasPrefix(original.id.uuidString) }
    }

    func moveMovement(_ id: UUID, to targetID: UUID) {
        guard !isSaving, !hasInvalidNumbers, let from = movements.firstIndex(where: { $0.id == id }),
              let to = movements.firstIndex(where: { $0.id == targetID }), from != to else { return }
        movements.insert(movements.remove(at: from), at: to)
    }

    func replaceMovement(_ id: UUID, with exercise: ExerciseSnapshot) {
        endRepsEditing(id)
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
        movements[index].restSeconds = max(minimumRest, value)
    }

    func numberText(_ field: String, movement: MovementConfig) -> String {
        let value = field == "Sets" ? movement.sets : field == "Reps" ? movement.reps : movement.restSeconds
        return numberInputs["\(movement.id).\(field)"] ?? String(value)
    }

    func numberHasError(_ field: String, id: UUID) -> Bool { numberErrors.contains("\(id).\(field)") }

    /// Clears valid repetitions on focus without changing the workout prescription.
    func beginRepsEditing(_ id: UUID) {
        guard originalEditingReps[id] == nil, let movement = movements.first(where: { $0.id == id }) else { return }
        originalEditingReps[id] = movement.reps
        if !numberHasError("Reps", id: id) { numberInputs["\(id).Reps"] = "" }
    }

    /// Restores the value from focus entry if repetitions are empty. Repeated calls are harmless.
    func endRepsEditing(_ id: UUID) {
        guard let original = originalEditingReps.removeValue(forKey: id),
              movements.contains(where: { $0.id == id }) else { return }
        let key = "\(id).Reps"
        if numberInputs[key] == "" {
            setReps(original, forMovement: id)
            numberInputs.removeValue(forKey: key)
            numberErrors.remove(key)
        }
    }

    /// Finalizes numeric input before committing a movement or leaving its editor.
    func endNumberEditing() {
        for id in Array(originalEditingReps.keys) { endRepsEditing(id) }
    }

    func enterNumber(_ text: String, field: String, id: UUID) {
        guard movements.contains(where: { $0.id == id }) else { return }
        let key = "\(id).\(field)"
        numberInputs[key] = text
        if field == "Reps", text.isEmpty, let original = originalEditingReps[id] {
            setReps(original, forMovement: id)
            numberErrors.remove(key)
            return
        }
        guard let value = WorkoutNumberParser().integer(text, minimum: field == "Rest" ? minimumRest : 1) else {
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
        endNumberEditing()
        guard let movement = movements.first(where: { $0.id == id }) else { return }
        let value = field == "Sets" ? movement.sets : field == "Reps" ? movement.reps : movement.restSeconds
        let step = field == "Rest" ? 15 : 1
        let next = max(field == "Rest" ? minimumRest : 1, min(Int(Int32.max), value + (increasing ? step : -step)))
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
        endNumberEditing()
        guard canSave, requestedWorkoutID == nil || editingWorkout != nil else { return false }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            if !isEditMode && mode == .smart && targetMuscleGroups.isEmpty {
                errorMessage = String(localized: .uiNoExercisesMatchTryDifferentMuscleGroups)
                return false
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

            workout.items = workoutItems

            if var context = smartContext {
                context.variant.items = workout.items
                context.variant.estimatedSeconds = estimatedDurationSeconds
                context.variant.uncoveredNeeds = []
                try await workoutsRepository.save(workout, dailyVariant: context.variant)
                smartContext = SmartEditorContext(workout: workout, variant: context.variant,
                                                  isExisting: true, requiresSave: false)
            } else {
                try await workoutsRepository.save(workout)
            }
            savedWorkout = workout
            editingWorkout = workout
            initialDraft = draft
            await onScheduleChanged()
            return true
        } catch {
            errorMessage = String(localized: .uiCouldNotSaveSession)
            return false
        }
    }

    func refreshSmartMovements() {
        guard !isDailySmart, !isPopulating, mode == .smart, !targetMuscleGroups.isEmpty, !allExercises.isEmpty else { return }
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
        originalEditingReps = [:]
    }

    /// Keeps complete exercises, preserving their IDs and edited parameters within the budget.
    func applySmartTimeBudget() {
        guard !isDailySmart, mode == .smart else { return }
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
        originalEditingReps = originalEditingReps.filter { remaining.contains($0.key.uuidString) }
        numberInputs = numberInputs.filter { remaining.contains(String($0.key.prefix(36))) }
        numberErrors = numberErrors.filter { remaining.contains(String($0.prefix(36))) }
    }

    private var workoutItems: [WorkoutItemSnapshot] {
        movements.enumerated().map { index, movement in
            WorkoutItemSnapshot(id: movement.id, order: index, sets: movement.sets, targetReps: movement.reps,
                                restSeconds: movement.restSeconds, exercise: movement.exercise)
        }
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
