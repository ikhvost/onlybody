import Foundation
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
final class MockWorkoutRepository: WorkoutRepository {
    var stubbedWorkouts: [WorkoutSnapshot] = []
    var shouldThrow = false
    var deletedIDs: [UUID] = []
    var savedWorkouts: [WorkoutSnapshot] = []

    func allWorkouts() async throws -> [WorkoutSnapshot] {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        return stubbedWorkouts
    }

    func workout(by id: UUID) async throws -> WorkoutSnapshot? {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        return stubbedWorkouts.first { $0.id == id }
    }

    func delete(by id: UUID) async throws {
        if shouldThrow { throw TestError.expectedFailure }
        deletedIDs.append(id)
        stubbedWorkouts.removeAll { $0.id == id }
    }

    func save(_ workout: WorkoutSnapshot) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        savedWorkouts.append(workout)
    }

}
