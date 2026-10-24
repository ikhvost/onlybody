import Foundation

nonisolated struct SmartWorkoutGenerator: Sendable {

    let randomSets: @Sendable (ClosedRange<Int>) -> Int
    let randomReps: @Sendable (ClosedRange<Int>) -> Int
    let randomRest: @Sendable ([Int]) -> Int

    init(
        randomSets: @escaping @Sendable (ClosedRange<Int>) -> Int = { Int.random(in: $0) },
        randomReps: @escaping @Sendable (ClosedRange<Int>) -> Int = { Int.random(in: $0) },
        randomRest: @escaping @Sendable ([Int]) -> Int = { $0.randomElement() ?? 45 }
    ) {
        self.randomSets = randomSets
        self.randomReps = randomReps
        self.randomRest = randomRest
    }

    func generate(config: SmartWorkoutConfiguration, from exercises: [ExerciseSnapshot]) -> [GeneratedMovement] {
        let expanded = expandTargets(config.targetMuscleGroups)

        let pool = filteredPool(from: exercises, matching: expanded)

        if pool.isEmpty {
            return []
        }

        let items = buildMovements(pool: pool, timeBudget: config.durationMinutes * 60)

        guard items.count >= 2 else {
            return buildMovements(
                pool: filteredPool(from: exercises.filter { exercise in
                    exercise.equipment.contains("None")
                }, matching: expanded),
                timeBudget: config.durationMinutes * 60
            )
        }

        return items
    }

    private func filteredPool(from exercises: [ExerciseSnapshot], matching expanded: [String]) -> [ExerciseSnapshot] {
        exercises
            .filter { exercise in
                expanded.contains(exercise.primaryMuscle)
                    || !Set(exercise.secondaryMuscles).isDisjoint(with: Set(expanded))
            }
            .filter { ExerciseFrequency(rawValue: $0.frequencyPreference) != .never }
            .sorted {
                (ExerciseFrequency(rawValue: $0.frequencyPreference) ?? .normal).rank
                    < (ExerciseFrequency(rawValue: $1.frequencyPreference) ?? .normal).rank
            }
    }

    private func buildMovements(pool: [ExerciseSnapshot], timeBudget: Int) -> [GeneratedMovement] {
        var items: [GeneratedMovement] = []
        var totalSeconds = 0

        for exercise in pool {
            let sets = randomSets(3...4)
            let reps = randomReps(8...15)
            let rest = randomRest([30, 45, 60, 90])
            let estDuration = sets * 30 + (sets - 1) * rest

            guard totalSeconds + estDuration <= timeBudget || items.isEmpty else {
                continue
            }

            items.append(GeneratedMovement(
                exercise: exercise,
                sets: sets,
                reps: reps,
                restSeconds: rest
            ))
            totalSeconds += estDuration
        }

        return items
    }

    private func expandTargets(_ groups: [String]) -> [String] {
        var expanded = Set<String>()

        for group in groups {
            switch group {
            case "Full Body":
                expanded.formUnion(ExerciseCatalog.allMuscles)
            case "Upper":
                expanded.formUnion(ExerciseCatalog.upperMuscles)
            case "Lower":
                expanded.formUnion(ExerciseCatalog.lowerMuscles)
            default:
                expanded.insert(group)
            }
        }

        return Array(expanded)
    }
}
