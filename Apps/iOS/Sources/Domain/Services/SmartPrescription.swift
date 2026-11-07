import Foundation

/// Explicit general-fitness defaults; never assigns weight or shortens rest to fill time.
nonisolated struct SmartPrescription: Sendable {
    func movement(_ exercise: ExerciseSnapshot, level: ExerciseDifficulty) -> GeneratedMovement {
        let main = exercise.smartMetadata?.role == .main
        let sets = main ? (level == .advanced ? 4 : 3) : (level == .beginner ? 2 : 3)
        return GeneratedMovement(exercise: exercise, sets: sets,
                                 reps: main ? (level == .beginner ? 10 : 8) : 12, restSeconds: main ? 90 : 60)
    }

    func seconds(_ movement: GeneratedMovement) -> Int {
        guard let metadata = movement.exercise.smartMetadata else { return 0 }
        let repetitions = movement.reps * metadata.repetitionRule.multiplier * metadata.repetitionSeconds
        return metadata.setupSeconds + metadata.transitionSeconds + movement.sets * (repetitions + movement.restSeconds)
    }

    func seconds(_ items: [WorkoutItemSnapshot]) -> Int {
        items.reduce(0) { total, item in
            guard let exercise = item.exercise else { return total }
            return total + seconds(GeneratedMovement(exercise: exercise, sets: item.sets,
                                                     reps: item.targetReps, restSeconds: item.restSeconds))
        }
    }
}
