nonisolated struct ExerciseCatalog {
    static let primaryMuscles = allMuscles + ["Full Body"]

    static let sessionTargets = primaryMuscles + ["Upper", "Lower"]
    static let filters = ["All"] + primaryMuscles
    static let equipment = [
        "None",
        "Wall",
        "Stable Support",
        "Elevated Surface",
        "Pull-up Bar",
        "Dip Bar",
        "Low Bar",
        "Towel",
        "Fixed Ankle Support"
    ]

    static let allMuscles = MuscleGroup.allCases.map(\.rawValue)
    static let upperMuscles = ["Chest", "Back", "Shoulders", "Biceps", "Triceps", "Forearms", "Serratus"]
    static let lowerMuscles = ["Quads", "Glutes", "Hamstrings", "Calves", "Hip Flexors", "Adductors"]
}
