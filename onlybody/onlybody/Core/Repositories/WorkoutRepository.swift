import Foundation

protocol WorkoutRepository: Sendable {
    func allWorkouts() async throws -> [Workout]
    func workout(by id: UUID) async throws -> Workout?
    func save(_ workout: Workout) async throws
    func deleteItems(_ items: [WorkoutItem]) async throws
}
