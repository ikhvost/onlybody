import Foundation

@MainActor
extension Session {
    func snapshot() -> SessionSnapshot {
        SessionSnapshot(
            id: id,
            date: date,
            durationSeconds: durationSeconds,
            workoutName: workoutName,
            items: (items ?? []).sorted { $0.order < $1.order }.map { $0.snapshot() }
        )
    }
}
