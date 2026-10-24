import Foundation

/// Persistence boundary exposing detached domain values.
@MainActor
protocol WorkoutRepository: Sendable {
    /// Returns detached workouts sorted by name, with ordered items.
    func allWorkouts() async throws -> [WorkoutSnapshot]
    /// Returns nil when the workout no longer exists.
    func workout(by id: UUID) async throws -> WorkoutSnapshot?
    /// Atomically replaces a workout aggregate by UUID; failure leaves stored data unchanged.
    func save(_ workout: WorkoutSnapshot) async throws
}
