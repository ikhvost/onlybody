import Foundation

/// Multiple-choice knapsack: retain coverage, vary sets, and use at most one exercise per family.
nonisolated struct SmartDurationFiller: Sendable {
    func fill(required: [GeneratedMovement], candidates: [ExerciseSnapshot],
              configuration: SmartWorkoutConfiguration, fixedNames: Set<String> = []) -> [GeneratedMovement] {
        let prescription = SmartPrescription()
        let budget = max(0, min(configuration.durationMinutes, 120)) * 60
        let grouped = Dictionary(grouping: candidates) { $0.smartMetadata?.family ?? "" }
        let ranks = Dictionary(uniqueKeysWithValues: candidates.enumerated().map { ($0.element.name, $0.offset) })
        let anchors = Dictionary(uniqueKeysWithValues: required.map { ($0.exercise.smartMetadata?.family ?? "", $0.exercise) })
        let families = grouped.keys.sorted {
            let first = anchors[$0] ?? grouped[$0]?.first
            let second = anchors[$1] ?? grouped[$1]?.first
            if first?.smartMetadata?.role != second?.smartMetadata?.role { return first?.smartMetadata?.role == .main }
            return (ranks[first?.name ?? ""] ?? 0) < (ranks[second?.name ?? ""] ?? 0)
        }
        var states = [0: SmartBudgetState()]
        for family in families {
            let anchor = required.first { $0.exercise.smartMetadata?.family == family }
            let preferred = anchor?.exercise ?? grouped[family]?.first
            let muscles = SmartTargetPolicy().muscles(for: configuration.targetMuscleGroups)
            let needed = Set(anchor?.exercise.primaryMuscles ?? []).intersection(muscles)
            let exercises = (grouped[family] ?? []).filter { exercise in
                exercise.smartMetadata?.role == preferred?.smartMetadata?.role
                    && needed.isSubset(of: Set(exercise.primaryMuscles))
                    && (anchor == nil || !fixedNames.contains(anchor?.exercise.name ?? "") || exercise.name == anchor?.exercise.name)
            }
            let options = exercises.flatMap { exercise in
                prescription.setRange.map { sets in
                    var movement = prescription.movement(exercise)
                    movement.sets = sets
                    return movement
                }
            }
            var next: [Int: SmartBudgetState] = anchor == nil ? states : [:]
            // Sorted traversal and an explicit tie-break keep equal-cost solutions reproducible.
            for key in states.keys.sorted() {
                guard let state = states[key] else { continue }
                for movement in options {
                    let seconds = state.seconds + (state.movements.last?.restSeconds ?? 0)
                        + prescription.seconds(movement) - movement.restSeconds
                    guard seconds <= budget else { continue }
                    let candidate = SmartBudgetState(movements: state.movements + [movement], seconds: seconds,
                        preferenceCost: state.preferenceCost + 1_000 + (ranks[movement.exercise.name] ?? 0))
                    if let existing = next[candidate.key], existing.preferenceCost <= candidate.preferenceCost { continue }
                    next[candidate.key] = candidate
                }
            }
            states = next
        }
        return states.keys.sorted().compactMap { states[$0] }.sorted {
            if $0.seconds != $1.seconds { return $0.seconds > $1.seconds }
            return $0.preferenceCost < $1.preferenceCost
        }.first?.movements ?? required
    }
}
