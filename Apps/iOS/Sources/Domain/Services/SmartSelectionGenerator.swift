import Foundation

/// Pure, reproducible selection. Unknown metadata and unconfirmed constraints never become automatic matches.
nonisolated struct SmartSelectionGenerator: Sendable {

    func generate(config: SmartWorkoutConfiguration, from exercises: [ExerciseSnapshot]) -> [GeneratedMovement] {
        plan(configuration: config, from: exercises).movements
    }

    func plan(configuration: SmartWorkoutConfiguration, from exercises: [ExerciseSnapshot],
              context: SmartGenerationContext = SmartGenerationContext()) -> SmartGenerationResult {
        let policy = SmartTargetPolicy()
        guard policy.isValid(configuration.targetMuscleGroups) else {
            return SmartGenerationResult(uncoveredNeeds: ["selection"])
        }
        let targets = policy.muscles(for: configuration.targetMuscleGroups)
        let candidates = exercises.filter {
            isEligible($0, configuration: configuration) && !Set($0.primaryMuscles).isDisjoint(with: targets)
        }.sorted { precedes($0, $1, context: context) }
        let required = coverage(configuration: configuration, candidates: candidates, anchors: context.mainExerciseNames)
        let requiredNames = Set(required.map(\.exercise.name))
        let fillingCandidates = candidates.filter {
            context.mainExerciseNames.isEmpty || $0.smartMetadata?.role != .main || requiredNames.contains($0.name)
        }
        let movements = SmartDurationFiller().fill(required: required, candidates: fillingCandidates,
                                                  configuration: configuration, fixedNames: Set(context.mainExerciseNames))
            .sorted { precedes($0.exercise, $1.exercise, context: context) }
        let items = movements.enumerated().map {
            WorkoutItemSnapshot(order: $0.offset, sets: $0.element.sets, targetReps: $0.element.reps,
                                restSeconds: $0.element.restSeconds, exercise: $0.element.exercise)
        }
        let assessment = SmartPlanAssessment(configuration: configuration, items: items)
        return SmartGenerationResult(movements: movements, estimatedSeconds: assessment.estimatedSeconds,
                                     uncoveredNeeds: assessment.gaps, status: assessment.status)
    }

    func isEligible(_ exercise: ExerciseSnapshot, configuration: SmartWorkoutConfiguration, ignoringLoads: Bool = false) -> Bool {
        guard let metadata = exercise.smartMetadata,
              SmartRegionRestrictions.allows(exercise.name, excluding: configuration.excludedRegions) else { return false }
        let equipmentMatches = configuration.equipmentMode == .standardGym || exercise.equipment.allSatisfy {
            $0 == "None" || configuration.availableEquipment.contains($0)
        }
        return equipmentMatches && (ignoringLoads || metadata.loads.isDisjoint(with: configuration.excludedLoads))
    }

    /// At most three exercises are needed to establish the requested coverage. Keep several
    /// alternatives so an expensive first match cannot crowd another requested muscle out.
    private func coverage(configuration: SmartWorkoutConfiguration, candidates: [ExerciseSnapshot], anchors: [String]) -> [GeneratedMovement] {
        let policy = SmartTargetPolicy()
        let prescription = SmartPrescription()
        let budget = max(0, min(configuration.durationMinutes, 120)) * 60
        var initial = candidates.indices.filter { anchors.contains(candidates[$0].name) }
        let movements = candidates.map { exercise in
            var movement = prescription.movement(exercise)
            movement.sets = prescription.setRange.lowerBound
            return movement
        }
        if prescription.totalSeconds(initial.map { movements[$0] }) > budget { initial = [] }
        var frontier = [initial]
        var best = initial
        func gaps(_ indices: [Int]) -> Int {
            policy.gaps(targets: configuration.targetMuscleGroups, exercises: indices.map { candidates[$0] }).count
        }
        if gaps(initial) == 0 { return initial.map { movements[$0] } }
        for _ in 0..<3 {
            var next = expandedCoverage(frontier, candidates: candidates, movements: movements, budget: budget)
            next.sort {
                let firstGaps = gaps($0), secondGaps = gaps($1)
                if firstGaps != secondGaps { return firstGaps < secondGaps }
                return $0.lexicographicallyPrecedes($1)
            }
            guard let first = next.first else { break }
            if gaps(first) < gaps(best) { best = first }
            if gaps(first) == 0 { return first.map { movements[$0] } }
            frontier = Array(next.prefix(64))
        }
        return best.map { movements[$0] }
    }

    private func expandedCoverage(_ frontier: [[Int]], candidates: [ExerciseSnapshot],
                                  movements: [GeneratedMovement], budget: Int) -> [[Int]] {
        let prescription = SmartPrescription()
        var next: [[Int]] = []
        for indices in frontier {
            let families = Set(indices.compactMap { candidates[$0].smartMetadata?.family })
            for index in candidates.indices where index > (indices.last ?? -1) {
                guard !families.contains(candidates[index].smartMetadata?.family ?? "") else { continue }
                let choice = indices + [index]
                guard prescription.totalSeconds(choice.map { movements[$0] }) <= budget else { continue }
                next.append(choice)
            }
        }
        return next
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

}
