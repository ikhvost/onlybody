import Foundation

/// Destinations stay inside the active workout's full-screen navigation stack.
enum ActiveWorkoutRoute: Hashable {
    case guide(exerciseID: UUID)
    case history(exerciseName: String)
}
