/// Broad regions used by the exercise catalog, not individual muscle activation measurements.
nonisolated enum MuscleGroup: String, CaseIterable, Sendable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case arms = "Arms"
    case core = "Core"
    case quads = "Quads"
    case glutes = "Glutes"
    case hamstrings = "Hamstrings"
    case calves = "Calves"
}
