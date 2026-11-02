import Foundation
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
final class MockExerciseRepository: ExerciseRepository {
    var stubbedAllExercises: [ExerciseSnapshot] = []
    var shouldThrow = false
    var savedExercises: [ExerciseSnapshot] = []

    func allExercises() async throws -> [ExerciseSnapshot] {
        if shouldThrow {
            throw TestError.expectedFailure
        }

        return stubbedAllExercises
    }

    func save(_ exercise: ExerciseSnapshot) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }

        savedExercises.append(exercise)
    }
}
