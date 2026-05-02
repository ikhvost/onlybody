import Foundation

struct SmartWorkoutGenerator {
    struct Config {
        let targetMuscleGroups: [String]
        let durationMinutes: Int

        init(targetMuscleGroups: [String], durationMinutes: Int = 30) {
            self.targetMuscleGroups = targetMuscleGroups
            self.durationMinutes = durationMinutes
        }
    }

    struct GeneratedMovement {
        let exercise: Exercise
        let sets: Int
        let reps: Int
        let restSeconds: Int
    }

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

    func generate(config: Config, from exercises: [Exercise]) -> [GeneratedMovement] {
        let expanded = expandTargets(config.targetMuscleGroups)

        let pool = exercises
            .filter { exercise in
                expanded.contains(exercise.primaryMuscle)
                    || !Set(exercise.secondaryMuscles).isDisjoint(with: Set(expanded))
            }
            .filter { $0.frequencyPreference != "never" }
            .sorted { preferenceRank($0.frequencyPreference) < preferenceRank($1.frequencyPreference) }

        if pool.isEmpty {
            return []
        }

        let items = buildMovements(pool: pool, timeBudget: config.durationMinutes * 60)

        guard items.count >= 2 else {
            let equipmentFree = exercises.filter { exercise in
                exercise.equipment.contains("None")
                    && (expanded.contains(exercise.primaryMuscle)
                        || !Set(exercise.secondaryMuscles).isDisjoint(with: Set(expanded)))
            }
            return buildMovements(
                pool: equipmentFree
                    .filter { $0.frequencyPreference != "never" }
                    .sorted { preferenceRank($0.frequencyPreference) < preferenceRank($1.frequencyPreference) },
                timeBudget: config.durationMinutes * 60
            )
        }

        return items
    }

    private func preferenceRank(_ p: String) -> Int {
        switch p {
        case "more": return 0
        case "less": return 2
        default: return 1
        }
    }

    private func buildMovements(pool: [Exercise], timeBudget: Int) -> [GeneratedMovement] {
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
                expanded.formUnion(Self.allMuscles)
            case "Upper":
                expanded.formUnion(Self.upperMuscles)
            case "Lower":
                expanded.formUnion(Self.lowerMuscles)
            default:
                expanded.insert(group)
            }
        }

        return Array(expanded)
    }

    private static let allMuscles = [
        "Chest", "Back", "Shoulders", "Arms",
        "Core", "Quads", "Glutes", "Hamstrings", "Calves"
    ]

    private static let upperMuscles = ["Chest", "Back", "Shoulders", "Arms"]

    private static let lowerMuscles = ["Quads", "Glutes", "Hamstrings", "Calves"]
}
