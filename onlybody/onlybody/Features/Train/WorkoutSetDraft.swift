/// Only edited or completed rows are materialized, even for very large plans.
struct WorkoutSetDraft {
    var reps: Int
    var weightKg: Double = 0
    var isDone = false
    var repsInput: String?
    var weightInput: String?
    var isReplacingInitialZero = false
    var invalidReps = false
    var invalidWeight = false
}
