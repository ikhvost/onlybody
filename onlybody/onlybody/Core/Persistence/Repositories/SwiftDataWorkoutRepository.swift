import Foundation
import SwiftData

/// Maps detached values to a private context and commits each aggregate atomically.
@MainActor
final class SwiftDataWorkoutRepository: WorkoutRepository {
    private let context: ModelContext
    private let catalog: [ExerciseSnapshot]

    init(context: ModelContext, catalog: [ExerciseSnapshot] = []) {
        self.context = context
        self.catalog = catalog
        context.autosaveEnabled = false
    }

    func allWorkouts() async throws -> [WorkoutSnapshot] {
        let descriptor = FetchDescriptor<Workout>(sortBy: [SortDescriptor(\Workout.name)])
        return try context.fetch(descriptor).map { $0.snapshot() }
    }

    func workout(by id: UUID) async throws -> WorkoutSnapshot? {
        var descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first?.snapshot()
    }

    func save(_ value: WorkoutSnapshot) async throws {
        do {
            let id = value.id
            var descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.id == id })
            descriptor.fetchLimit = 1
            let model = try context.fetch(descriptor).first ?? Workout()
            if model.modelContext == nil { context.insert(model) }
            model.id = value.id
            model.name = value.name
            model.mode = value.mode
            model.targetMuscleGroups = value.targetMuscleGroups
            model.scheduledDays = value.scheduledDays
            for item in model.items ?? [] { context.delete(item) }
            model.items = []
            for valueItem in value.items {
                let item = WorkoutItem()
                item.id = valueItem.id
                item.order = valueItem.order
                item.sets = valueItem.sets
                item.targetReps = valueItem.targetReps
                item.restSeconds = valueItem.restSeconds
                if let exercise = valueItem.exercise {
                    item.exercise = try resolveExercise(exercise)
                }
                item.workout = model
                model.items?.append(item)
            }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    /// Materialize only a selected new catalog entry in the workout's atomic transaction.
    private func resolveExercise(_ value: ExerciseSnapshot) throws -> Exercise {
        let id = value.id
        var descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first { return existing }
        guard let entry = catalog.first(where: { $0.id == value.id && $0.name == value.name }) else {
            throw PersistenceError.exerciseUnavailable
        }
        // Another screen may have saved this entry since the builder loaded its catalog.
        let name = entry.name
        var byName = FetchDescriptor<Exercise>(predicate: #Predicate { $0.name == name })
        byName.fetchLimit = 1
        if let existing = try context.fetch(byName).first { return existing }
        let model = Exercise()
        model.id = entry.id
        model.name = entry.name
        model.primaryMuscle = entry.primaryMuscle
        model.secondaryMuscles = entry.secondaryMuscles
        model.equipment = entry.equipment
        context.insert(model)
        return model
    }
}
