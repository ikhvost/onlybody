import Foundation
import SwiftData

/// Maps detached values to a private context and commits each aggregate atomically.
@MainActor
final class SwiftDataWorkoutRepository: WorkoutRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
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
                if let exerciseID = valueItem.exercise?.id {
                    var exercises = FetchDescriptor<Exercise>(predicate: #Predicate { $0.id == exerciseID })
                    exercises.fetchLimit = 1
                    guard let exercise = try context.fetch(exercises).first else {
                        throw PersistenceError.exerciseUnavailable
                    }
                    item.exercise = exercise
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
}
