import Foundation
import SwiftData

/// Maps detached values to a private context and commits each aggregate atomically.
@MainActor
final class SwiftDataExerciseRepository: ExerciseRepository {
    private let context: ModelContext
    private let catalog: [ExerciseSnapshot]

    init(context: ModelContext, catalog: [ExerciseSnapshot] = []) {
        self.context = context
        self.catalog = catalog
        context.autosaveEnabled = false
    }

    func allExercises() async throws -> [ExerciseSnapshot] {
        let descriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\Exercise.name)])
        let saved = try context.fetch(descriptor).map { $0.snapshot() }
        // Use the release's metadata while preserving IDs referenced by existing workouts.
        let current = catalog.map { entry in
            var value = entry
            if let existing = saved.first(where: { $0.name == entry.name }) {
                value.id = existing.id
            }
            return value
        }
        let currentNames = Set(catalog.map(\.name))
        return (current + saved.filter { !currentNames.contains($0.name) })
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
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
