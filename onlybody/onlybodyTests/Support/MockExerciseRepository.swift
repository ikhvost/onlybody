import Foundation
@testable import onlybody

@MainActor
final class MockExerciseRepository: ExerciseRepository {
    var stubbedAllExercises: [Exercise] = []
    var shouldThrow = false
    var savedExercises: [Exercise] = []

    func allExercises() async throws -> [Exercise] {
        if shouldThrow {
            throw TestError.expectedFailure
        }

        return stubbedAllExercises
    }

    func save(_ exercise: Exercise) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }

        savedExercises.append(exercise)
    }
}
