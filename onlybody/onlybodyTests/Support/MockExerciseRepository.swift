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

    func exercises(primaryMuscle: String) async throws -> [Exercise] {
        if shouldThrow {
            throw TestError.expectedFailure
        }

        return stubbedAllExercises.filter { $0.primaryMuscle == primaryMuscle }
    }

    func exercises(matching name: String) async throws -> [Exercise] {
        if shouldThrow {
            throw TestError.expectedFailure
        }

        return stubbedAllExercises.filter { $0.name.localizedStandardContains(name) }
    }

    func save(_ exercise: Exercise) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }

        savedExercises.append(exercise)
    }

    func delete(_ exercise: Exercise) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }
    }
}
