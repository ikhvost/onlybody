import Foundation

/// A detached value that never exposes a persistence context.
nonisolated struct WorkoutItemSnapshot: Identifiable, Sendable, Equatable {
    var id: UUID = UUID()
    var order: Int = 0
    var sets: Int = 3
    var targetReps: Int = 12
    var restSeconds: Int = 45
    var exercise: ExerciseSnapshot?

}
