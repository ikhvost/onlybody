import Foundation

@MainActor
extension WorkoutItem {
    func snapshot() -> WorkoutItemSnapshot {
        WorkoutItemSnapshot(
            id: id,
            order: order,
            sets: sets,
            targetReps: targetReps,
            restSeconds: restSeconds,
            exercise: exercise?.snapshot()
        )
    }
}
