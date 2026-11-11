import Foundation

nonisolated struct SmartGenerationResult: Sendable {
    var movements: [GeneratedMovement] = []
    var estimatedSeconds: Int = 0
    var uncoveredNeeds: [String] = []
    var status: SmartPlanStatus = .unavailable

    var canStart: Bool { status == .complete }

    var items: [WorkoutItemSnapshot] {
        movements.enumerated().map { index, movement in
            WorkoutItemSnapshot(order: index, sets: movement.sets, targetReps: movement.reps,
                                restSeconds: movement.restSeconds, exercise: movement.exercise)
        }
    }
}
