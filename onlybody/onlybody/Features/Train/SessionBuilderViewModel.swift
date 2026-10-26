import Foundation
import Observation

@MainActor
@Observable
final class SessionBuilderViewModel {
    private let workoutsRepository: any WorkoutRepository
    private let exercisesRepository: any ExerciseRepository
    private let smartGenerator: SmartWorkoutGenerator
    private let onScheduleChanged: @MainActor () async -> Void

    private var initialDraft: BuilderDraft?
    var hasUnsavedChanges: Bool { initialDraft != draft }

    private var draft: BuilderDraft {
        BuilderDraft(name: name, mode: mode, targets: Set(targetMuscleGroups),
                     movements: movements, durationMinutes: durationMinutes, restSeconds: restSeconds, days: Set(scheduledDays))
    }

    let editingWorkout: WorkoutSnapshot?

    var name: String = ""
    var mode: WorkoutMode = .smart
    var targetMuscleGroups: [String] = []
    var movements: [MovementConfig] = []
    var scheduledDays: [String] = []
    private(set) var durationMinutes = 30
    private(set) var restSeconds = 45
    var hasMixedRest: Bool { movements.contains { $0.restSeconds != restSeconds } }
    var isSaving = false
    var errorMessage: String?
    var allExercises: [ExerciseSnapshot] = []

    let dayNames = Weekdays.shortNames

    var isEditMode: Bool {
        editingWorkout != nil
    }

    var estimatedDurationSeconds: Int {
        movements.reduce(0) { total, movement in
            let perSetTime = 30
            let restTime = max(0, movement.sets - 1) * movement.restSeconds
            return total + movement.sets * perSetTime + restTime
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
        generator: SmartWorkoutGenerator = SmartWorkoutGenerator(),
        onScheduleChanged: @escaping @MainActor () async -> Void = {}
    ) {
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
    }

    func loadExercises() async {
        do {
            allExercises = try await exercisesRepository.allExercises()
        } catch {
            errorMessage = String(localized: .uiCouldNotLoadExercises)
        }
    }

    func addMovement(_ exercise: ExerciseSnapshot) {
        let config = MovementConfig(exercise: exercise, restSeconds: restSeconds)
        movements.append(config)
    }

    func setDurationMinutes(_ value: Int) {
        guard WorkoutTimingOptions.durations.contains(value) else { return }
        durationMinutes = value
    }

    func setDefaultRestSeconds(_ value: Int) {
        guard WorkoutTimingOptions.rests.contains(value) else { return }
        restSeconds = value
        for index in movements.indices { movements[index].restSeconds = value }
    }

    func removeMovement(_ id: UUID) {
        movements.removeAll { $0.id == id }
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
        guard !isSaving else { return false }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            if mode == .smart && targetMuscleGroups.isEmpty {
                mode = .manual
            }

            let needsGeneration = editingWorkout == nil || movements.isEmpty || initialDraft?.mode != .smart
                || initialDraft?.targets != Set(targetMuscleGroups)
                || initialDraft?.durationMinutes != durationMinutes || initialDraft?.restSeconds != restSeconds
            if mode == .smart && !targetMuscleGroups.isEmpty && needsGeneration {
                let config = SmartWorkoutConfiguration(
                    targetMuscleGroups: targetMuscleGroups,
                    durationMinutes: durationMinutes,
                    restSeconds: restSeconds
                )
                let generated = smartGenerator.generate(config: config, from: allExercises)

                guard !generated.isEmpty else {
                    errorMessage = String(localized: .uiNoExercisesMatchTryDifferentMuscleGroups)
                    return false
                }

                movements = generated.map {
                    MovementConfig(
                        exercise: $0.exercise,
                        sets: $0.sets,
                        reps: $0.reps,
                        restSeconds: $0.restSeconds
                    )
                }
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
            workout.durationMinutes = durationMinutes
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

    private func populateFrom(_ workout: WorkoutSnapshot) {
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
