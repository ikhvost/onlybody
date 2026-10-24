/// Planning choices; a target duration never cuts off an active workout.
nonisolated enum WorkoutTimingOptions {
    static let durations = Array(stride(from: 15, through: 60, by: 5))
    static let rests = Array(stride(from: 15, through: 180, by: 15))
}
