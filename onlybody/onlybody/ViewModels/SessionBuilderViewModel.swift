import Foundation
import Observation

@MainActor
@Observable
final class SessionBuilderViewModel {
    private let workoutsRepository: any WorkoutRepository
    private let exercisesRepository: any ExerciseRepository

    let editingWorkout: Workout?

    var name: String = ""
    var mode: String = "manual"
    var movements: [MovementConfig] = []
    var scheduledDays: [String] = []
    var isSaving = false
    var errorMessage: String?
    var allExercises: [Exercise] = []

    let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

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
        workout: Workout? = nil
    ) {
        self.workoutsRepository = workouts
        self.exercisesRepository = exercises
        self.editingWorkout = workout

        if let workout {
            populateFrom(workout)
        }
    }

    func loadExercises() async {
        do {
            allExercises = try await exercisesRepository.allExercises()
        } catch {
            errorMessage = "Could not load exercises."
        }
    }

    func addMovement(_ exercise: Exercise) {
        let config = MovementConfig(exercise: exercise)
        movements.append(config)
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

    func save() async -> Bool {
        guard !isSaving else { return false }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            let workout: Workout
            if let existing = editingWorkout {
                workout = existing
            } else {
                workout = Workout()
            }

            workout.name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? "My Session"
                : name.trimmingCharacters(in: .whitespacesAndNewlines)
            workout.mode = mode
            workout.scheduledDays = scheduledDays

            if let existingItems = workout.items {
                workout.items = nil
                for item in existingItems {
                    item.workout = nil
                }
            }

            var newItems: [WorkoutItem] = []
            for (index, movement) in movements.enumerated() {
                let item = WorkoutItem()
                item.order = index
                item.sets = movement.sets
                item.targetReps = movement.reps
                item.restSeconds = movement.restSeconds
                item.exercise = movement.exercise
                item.workout = workout
                newItems.append(item)
            }
            workout.items = newItems

            try await workoutsRepository.save(workout)
            return true
        } catch {
            errorMessage = "Could not save session."
            return false
        }
    }

    private func populateFrom(_ workout: Workout) {
        name = workout.name
        mode = workout.mode
        scheduledDays = workout.scheduledDays

        if let items = workout.items {
            let sorted = items.sorted(by: { $0.order < $1.order })
            movements = sorted.compactMap { item in
                guard let exercise = item.exercise else { return nil }
                return MovementConfig(
                    exercise: exercise,
                    sets: item.sets,
                    reps: item.targetReps,
                    restSeconds: item.restSeconds
                )
            }
        }
    }
}

struct MovementConfig: Identifiable {
    let id = UUID()
    let exercise: Exercise
    var sets: Int = 3
    var reps: Int = 12
    var restSeconds: Int = 45
}
