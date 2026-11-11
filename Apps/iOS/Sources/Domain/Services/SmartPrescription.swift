import Foundation

/// Explicit general-fitness defaults; never assigns weight or shortens rest to fill time.
nonisolated struct SmartPrescription: Sendable {
    let setRange = 2...3

    func movement(_ exercise: ExerciseSnapshot) -> GeneratedMovement {
        let main = exercise.smartMetadata?.role == .main
        return GeneratedMovement(exercise: exercise, sets: main ? 3 : 2,
                                 reps: main ? 10 : 12, restSeconds: main ? 90 : 60)
    }

    func seconds(_ movement: GeneratedMovement) -> Int {
        guard let metadata = movement.exercise.smartMetadata else {
            return WorkoutDurationEstimator().seconds(sets: movement.sets, reps: movement.reps, restSeconds: movement.restSeconds)
        }
        let repetitions = multiplied(multiplied(movement.reps, by: metadata.repetitionRule.multiplier), by: metadata.repetitionSeconds)
        let perSet = WorkoutDurationEstimator().adding(movement.restSeconds, to: repetitions)
        let work = multiplied(movement.sets, by: perSet)
        return WorkoutDurationEstimator().adding(metadata.setupSeconds + metadata.transitionSeconds, to: work)
    }

    func seconds(_ items: [WorkoutItemSnapshot]) -> Int {
        let total = items.reduce(0) { total, item in
            guard let exercise = item.exercise else { return total }
            let duration = seconds(GeneratedMovement(exercise: exercise, sets: item.sets,
                                                    reps: item.targetReps, restSeconds: item.restSeconds))
            return WorkoutDurationEstimator().adding(duration, to: total)
        }
        return max(0, total - (items.last?.restSeconds ?? 0))
    }

    private func multiplied(_ value: Int, by multiplier: Int) -> Int {
        let result = value.multipliedReportingOverflow(by: multiplier)
        return result.overflow ? Int.max : result.partialValue
    }

    func totalSeconds(_ movements: [GeneratedMovement]) -> Int {
        max(0, movements.reduce(0) { $0 + seconds($1) } - (movements.last?.restSeconds ?? 0))
    }
}
