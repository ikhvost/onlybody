/// Maps resolved catalog muscle roles to the anatomy illustration.
nonisolated struct MuscleDiagram: Equatable, Sendable {
    let primary: [MuscleGroup]
    let secondary: [MuscleGroup]
    let isFullBody: Bool

    init(primaryMuscles: [String], secondaryMuscles: [String], isFullBody: Bool = false) {
        primary = MuscleGroup.allCases.filter { primaryMuscles.contains($0.rawValue) }
        secondary = MuscleGroup.allCases.filter {
            secondaryMuscles.contains($0.rawValue) && !primaryMuscles.contains($0.rawValue)
        }
        self.isFullBody = isFullBody
    }

    init(primaryMuscle: String, secondaryMuscles: [String]) {
        self.init(primaryMuscles: [primaryMuscle], secondaryMuscles: secondaryMuscles, isFullBody: primaryMuscle == "Full Body")
    }

    var hasHighlightedRegions: Bool { !primary.isEmpty || !secondary.isEmpty }
}
