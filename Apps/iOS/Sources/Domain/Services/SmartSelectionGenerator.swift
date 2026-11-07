import Foundation

/// Pure, reproducible selection. Unknown metadata and unconfirmed constraints never become automatic matches.
nonisolated struct SmartSelectionGenerator: Sendable {

    func generate(config: SmartWorkoutConfiguration, from exercises: [ExerciseSnapshot]) -> [GeneratedMovement] {
        plan(configuration: config, from: exercises).movements
    }

    func plan(configuration: SmartWorkoutConfiguration, from exercises: [ExerciseSnapshot],
              context: SmartGenerationContext = SmartGenerationContext()) -> SmartGenerationResult {
        let candidates = exercises.filter { isEligible($0, configuration: configuration) }
        let needs = requirements(configuration.targetMuscleGroups)
        let targets = expandedTargets(configuration.targetMuscleGroups)
        let prescription = SmartPrescription()
        let budget = max(0, min(configuration.durationMinutes, 120)) * 60
        var selected: [GeneratedMovement] = []
        var families: Set<String> = []
        for need in needs {
            guard !selected.contains(where: { covers($0.exercise, need: need) }) else { continue }
            let matches = candidates.filter { exercise in
                covers(exercise, need: need) && !families.contains(exercise.smartMetadata?.family ?? "")
            }.sorted { precedes($0, $1, context: context) }
            if let exercise = matches.first, let metadata = exercise.smartMetadata {
                selected.append(prescription.movement(exercise, level: configuration.level))
                families.insert(metadata.family)
            }
        }
        // Preserve movement coverage before using spare time for additional work.
        trimToBudget(&selected, budget: budget)
        let accessories = candidates.filter {
            $0.smartMetadata?.role == .accessory && !Set($0.primaryMuscles).isDisjoint(with: targets)
        }.sorted { precedes($0, $1, context: context) }
        for exercise in accessories {
            guard let metadata = exercise.smartMetadata, !families.contains(metadata.family) else { continue }
            var movement = prescription.movement(exercise, level: configuration.level)
            let remaining = budget - selected.reduce(0) { $0 + prescription.seconds($1) }
            while movement.sets > 1, prescription.seconds(movement) > remaining { movement.sets -= 1 }
            guard prescription.seconds(movement) <= remaining else { continue }
            selected.append(movement)
            families.insert(metadata.family)
        }
        selected.sort { ($0.exercise.smartMetadata?.role == .main ? 0 : 1) < ($1.exercise.smartMetadata?.role == .main ? 0 : 1) }
        return SmartGenerationResult(movements: selected,
                                     estimatedSeconds: selected.reduce(0) { $0 + prescription.seconds($1) },
                                     uncoveredNeeds: needs.filter { need in !selected.contains { covers($0.exercise, need: need) } })
    }

    func isEligible(_ exercise: ExerciseSnapshot, configuration: SmartWorkoutConfiguration, ignoringLoads: Bool = false) -> Bool {
        guard let metadata = exercise.smartMetadata,
              SmartRegionRestrictions.allows(exercise.name, excluding: configuration.excludedRegions),
              let exerciseLevel = ExerciseDifficulty.ratedLevels.firstIndex(of: exercise.difficulty),
              let maximumLevel = ExerciseDifficulty.ratedLevels.firstIndex(of: configuration.level),
              exerciseLevel <= maximumLevel, !configuration.excludedExercises.contains(exercise.name) else { return false }
        let equipmentMatches = configuration.equipmentMode == .standardGym || exercise.equipment.allSatisfy {
            $0 == "None" || configuration.availableEquipment.contains($0)
        }
        return equipmentMatches && (ignoringLoads || metadata.loads.isDisjoint(with: configuration.excludedLoads))
    }

    func conflicts(_ exercise: ExerciseSnapshot, configuration: SmartWorkoutConfiguration) -> [ExerciseLoad] {
        guard let metadata = exercise.smartMetadata else { return [] }
        return ExerciseLoad.allCases.filter { metadata.loads.contains($0) && configuration.excludedLoads.contains($0) }
    }

    func uncoveredNeeds(configuration: SmartWorkoutConfiguration, items: [WorkoutItemSnapshot]) -> [String] {
        requirements(configuration.targetMuscleGroups).filter { need in
            !items.contains { item in item.exercise.map { covers($0, need: need) } ?? false }
        }
    }

    private func trimToBudget(_ items: inout [GeneratedMovement], budget: Int) {
        let prescription = SmartPrescription()
        for role in [SmartExerciseRole.accessory, .main] {
            for index in items.indices.reversed() where items[index].exercise.smartMetadata?.role == role {
                let minimum = role == .main ? 2 : 1
                while items[index].sets > minimum, items.reduce(0, { $0 + prescription.seconds($1) }) > budget {
                    items[index].sets -= 1
                }
            }
        }
        while items.reduce(0, { $0 + prescription.seconds($1) }) > budget, !items.isEmpty {
            if let index = items.lastIndex(where: { $0.exercise.smartMetadata?.role == .accessory }) {
                items.remove(at: index)
            } else { items.removeLast() }
        }
    }

    private func precedes(_ first: ExerciseSnapshot, _ second: ExerciseSnapshot, context: SmartGenerationContext) -> Bool {
        let firstMain = first.smartMetadata?.role == .main
        let secondMain = second.smartMetadata?.role == .main
        if firstMain != secondMain { return firstMain }
        let firstAnchor = context.mainExerciseNames.contains(first.name)
        let secondAnchor = context.mainExerciseNames.contains(second.name)
        if firstAnchor != secondAnchor { return firstAnchor }
        if !firstMain {
            let firstPrevious = context.previousExerciseNames.contains(first.name)
            let secondPrevious = context.previousExerciseNames.contains(second.name)
            if firstPrevious != secondPrevious { return !firstPrevious }
        }
        let seed = firstMain ? 0 : context.variationSeed
        let clock = SmartPlanningClock()
        let firstScore = clock.stableScore(first.name, seed: seed)
        let secondScore = clock.stableScore(second.name, seed: seed)
        return firstScore == secondScore ? first.name < second.name : firstScore < secondScore
    }

    private func covers(_ exercise: ExerciseSnapshot, need: String) -> Bool {
        if need.hasPrefix("movement:") {
            let movement = String(need.dropFirst("movement:".count))
            guard exercise.smartMetadata?.movement.rawValue == movement else { return false }
            return movement == "core" || exercise.smartMetadata?.role == .main
        }
        return exercise.primaryMuscles.contains(need)
    }

    private func requirements(_ groups: [String]) -> [String] {
        var needs: [String] = []
        for group in groups {
            switch group {
            case "Full Body": needs += ["movement:push", "movement:pull", "movement:squat", "movement:hinge", "movement:core"]
            case "Upper": needs += ["movement:push", "movement:pull"]
            case "Lower": needs += ["movement:squat", "movement:hinge"]
            case "Arms": needs += ["Biceps", "Triceps", "Forearms"]
            default: needs.append(group)
            }
        }
        var seen: Set<String> = []
        return needs.filter { seen.insert($0).inserted }
    }

    private func expandedTargets(_ groups: [String]) -> Set<String> {
        Set(groups.flatMap { group -> [String] in
            switch group {
            case "Full Body": ExerciseCatalog.allMuscles
            case "Upper": ExerciseCatalog.upperMuscles
            case "Lower": ExerciseCatalog.lowerMuscles
            case "Arms": ["Biceps", "Triceps", "Forearms"]
            default: [group]
            }
        })
    }
}
