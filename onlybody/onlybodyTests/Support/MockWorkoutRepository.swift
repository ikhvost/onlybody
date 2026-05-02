import Foundation
@testable import onlybody

@MainActor
final class MockWorkoutRepository: WorkoutRepository {
    var stubbedWorkouts: [Workout] = []
    var shouldThrow = false
    var savedWorkouts: [Workout] = []
    var deletedWorkouts: [Workout] = []
    var deletedItems: [WorkoutItem] = []

    func allWorkouts() async throws -> [Workout] {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        return stubbedWorkouts
    }

    func save(_ workout: Workout) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        savedWorkouts.append(workout)
    }

    func delete(_ workout: Workout) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        deletedWorkouts.append(workout)
    }

    func deleteItems(_ items: [WorkoutItem]) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        deletedItems.append(contentsOf: items)
    }
}
