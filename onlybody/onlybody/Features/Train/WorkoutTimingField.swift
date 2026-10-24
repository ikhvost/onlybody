enum WorkoutTimingField: String, Identifiable {
    case duration, rest
    var id: String { rawValue }
}
