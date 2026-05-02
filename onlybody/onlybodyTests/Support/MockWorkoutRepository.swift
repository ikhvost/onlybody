import Foundation
@testable import onlybody

@MainActor
final class MockWorkoutRepository: WorkoutRepository {
    var stubbedWorkouts: [Workout] = []
    var shouldThrow = false
    var savedWorkouts: [Workout] = []
    var deletedWorkouts: [Workout] = []

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
}
