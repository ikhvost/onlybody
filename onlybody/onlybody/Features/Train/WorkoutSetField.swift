/// Focus identity distinguishes both inputs across every set in an exercise.
enum WorkoutSetField: Hashable {
    case reps(WorkoutSetID)
    case weight(WorkoutSetID)
}
