/// Broad regions used by the exercise catalog, not individual muscle activation measurements.
nonisolated enum MuscleGroup: String, CaseIterable, Sendable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case forearms = "Forearms"
    case serratus = "Serratus"
    case hipFlexors = "Hip Flexors"
    case adductors = "Adductors"
    case core = "Core"
    case quads = "Quads"
    case glutes = "Glutes"
    case hamstrings = "Hamstrings"
    case calves = "Calves"
}
