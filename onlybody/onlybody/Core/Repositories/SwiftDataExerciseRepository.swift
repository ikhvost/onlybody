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

    func save(_ exercise: Exercise) async throws {
        if exercise.modelContext == nil {
            context.insert(exercise)
        }

        try context.save()
    }
}
