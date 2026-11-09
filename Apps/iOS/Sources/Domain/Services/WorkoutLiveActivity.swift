import Foundation

/// Publishes the active session's read-only presentation to the system.
@MainActor
protocol WorkoutLiveActivity {
    func start(sessionID: UUID, workoutName: String, state: WorkoutActivityState)
    func update(_ state: WorkoutActivityState)
    func end()
}
