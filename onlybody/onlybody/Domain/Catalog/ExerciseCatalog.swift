nonisolated struct ExerciseCatalog {
    static let primaryMuscles = [
        "Chest",
        "Back",
        "Shoulders",
        "Arms",
        "Core",
        "Quads",
        "Glutes",
        "Hamstrings",
        "Calves",
        "Full Body"
    ]

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

    static let allMuscles = [
        "Chest",
        "Back",
        "Shoulders",
        "Arms",
        "Core",
        "Quads",
        "Glutes",
        "Hamstrings",
        "Calves"
    ]

    static let upperMuscles = ["Chest", "Back", "Shoulders", "Arms"]
    static let lowerMuscles = ["Quads", "Glutes", "Hamstrings", "Calves"]
}
