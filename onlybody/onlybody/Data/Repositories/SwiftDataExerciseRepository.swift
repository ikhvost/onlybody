import Foundation
import SwiftData

@MainActor
final class SwiftDataExerciseRepository: ExerciseRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allExercises() async throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\Exercise.name)])
        return try context.fetch(descriptor)
    }

    func exercises(primaryMuscle: String) async throws -> [Exercise] {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.primaryMuscle == primaryMuscle
            },
            sortBy: [SortDescriptor(\Exercise.name)]
        )

        return try context.fetch(descriptor)
    }

    func exercises(matching name: String) async throws -> [Exercise] {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            return try await allExercises()
        }

        return try await allExercises().filter { exercise in
            exercise.name.localizedStandardContains(trimmedName)
        }
    }

    func save(_ exercise: Exercise) async throws {
        if exercise.modelContext == nil {
            context.insert(exercise)
        }

        try context.save()
    }

    func delete(_ exercise: Exercise) async throws {
        context.delete(exercise)
        try context.save()
    }
}
