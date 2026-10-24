import Foundation
import SwiftData

/// Maps detached values to a private context and commits each aggregate atomically.
@MainActor
final class SwiftDataExerciseRepository: ExerciseRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        context.autosaveEnabled = false
    }

    func allExercises() async throws -> [ExerciseSnapshot] {
        let descriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\Exercise.name)])
        return try context.fetch(descriptor).map { $0.snapshot() }
    }

    func save(_ value: ExerciseSnapshot) async throws {
        do {
            let id = value.id
            var descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.id == id })
            descriptor.fetchLimit = 1
            let model = try context.fetch(descriptor).first ?? Exercise()
            if model.modelContext == nil { context.insert(model) }
            model.id = value.id
            model.name = value.name
            model.primaryMuscle = value.primaryMuscle
            model.secondaryMuscles = value.secondaryMuscles
            model.equipment = value.equipment
            model.frequencyPreference = value.frequencyPreference
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
