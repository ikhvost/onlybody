/// Focus identity distinguishes both inputs across every set in an exercise.
enum WorkoutSetField: Hashable {
    case reps(WorkoutSetID)
    case weight(WorkoutSetID)

    /// The row owning either numeric field.
    var setID: WorkoutSetID {
        switch self {
        case .reps(let id), .weight(let id): id
        }
    }
}
