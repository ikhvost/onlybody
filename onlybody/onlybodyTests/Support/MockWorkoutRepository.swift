import Foundation
@testable import onlybody

@MainActor
final class MockWorkoutRepository: WorkoutRepository {
    var stubbedWorkouts: [Workout] = []
    var shouldThrow = false
    var savedWorkouts: [Workout] = []

    func allWorkouts() async throws -> [Workout] {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        return stubbedWorkouts
    }

    func workout(by id: UUID) async throws -> Workout? {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        return stubbedWorkouts.first { $0.id == id }
    }

    func save(_ workout: Workout) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        savedWorkouts.append(workout)
    }

    func deleteItems(_ items: [WorkoutItem]) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }
    }
}
