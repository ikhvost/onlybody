import Foundation

@MainActor
extension Workout {
    func snapshot() -> WorkoutSnapshot {
        WorkoutSnapshot(
            id: id,
            name: name,
            mode: mode,
            targetMuscleGroups: targetMuscleGroups,
            scheduledDays: scheduledDays,
            durationMinutes: durationMinutes,
            restSeconds: restSeconds,
            items: (items ?? []).sorted { $0.order < $1.order }.map { $0.snapshot() }
        )
    }
}
