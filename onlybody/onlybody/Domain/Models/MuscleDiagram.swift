/// Maps saved catalog labels to anatomy regions without relying on exercise IDs or names.
nonisolated struct MuscleDiagram: Equatable, Sendable {
    let primary: [MuscleGroup]
    let secondary: [MuscleGroup]
    let isFullBody: Bool

    init(primaryMuscle: String, secondaryMuscles: [String]) {
        primary = MuscleGroup(rawValue: primaryMuscle).map { [$0] } ?? []
        secondary = MuscleGroup.allCases.filter {
            secondaryMuscles.contains($0.rawValue) && $0.rawValue != primaryMuscle
        }
        // Full Body is a movement category, not evidence that every region is a prime mover.
        // For these exercises the diagram shows only the explicitly listed supporting groups.
        isFullBody = primaryMuscle == "Full Body"
    }

    var hasHighlightedRegions: Bool { !primary.isEmpty || !secondary.isEmpty }
}
