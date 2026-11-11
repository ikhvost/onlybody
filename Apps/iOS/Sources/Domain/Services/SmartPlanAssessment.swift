import Foundation

/// Assesses automatic selection quality. Manual editing and launching do not use these constraints.
nonisolated struct SmartPlanAssessment: Sendable {
    let estimatedSeconds: Int
    let gaps: [String]
    let status: SmartPlanStatus

    init(configuration: SmartWorkoutConfiguration, items: [WorkoutItemSnapshot]) {
        estimatedSeconds = SmartPrescription().seconds(items)
        var missing = SmartTargetPolicy().gaps(targets: configuration.targetMuscleGroups, exercises: items.compactMap(\.exercise))
        let targets = SmartTargetPolicy().muscles(for: configuration.targetMuscleGroups)
        let generator = SmartSelectionGenerator()
        if items.contains(where: { item in
            guard let exercise = item.exercise else { return true }
            return item.sets < 1 || item.targetReps < 1 || item.restSeconds < 0
                || !generator.isEligible(exercise, configuration: configuration)
                || Set(exercise.primaryMuscles).isDisjoint(with: targets)
        }) { missing.append("constraints") }
        if Set(items.compactMap { $0.exercise?.smartMetadata?.family }).count != items.count { missing.append("variety") }
        let budget = max(0, min(configuration.durationMinutes, 120)) * 60
        if estimatedSeconds > budget || budget == 0 { missing.append("time") }
        gaps = missing
        if !missing.isEmpty || items.isEmpty { status = .unavailable } else {
            status = estimatedSeconds * 10 >= budget * 9 ? .complete : .shorter
        }
    }
}
