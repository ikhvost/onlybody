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
        return try context.fetch(descriptor).map { try snapshot($0) }
    }

    func workout(by id: UUID) async throws -> WorkoutSnapshot? {
        var descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else { return nil }
        return try snapshot(model)
    }

    func delete(by id: UUID) async throws {
        do {
            var descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.id == id })
            descriptor.fetchLimit = 1
            guard let model = try context.fetch(descriptor).first else { return }
            for record in try context.fetch(FetchDescriptor<SmartWorkoutSettingsRecord>(predicate: #Predicate { $0.workoutID == id })) {
                context.delete(record)
            }
            for record in try context.fetch(FetchDescriptor<SmartDailyVariantRecord>(predicate: #Predicate { $0.workoutID == id })) {
                context.delete(record)
            }
            context.delete(model)
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func save(_ value: WorkoutSnapshot) async throws {
        try saveAggregate(value, dailyVariant: nil)
    }

    func save(_ value: WorkoutSnapshot, dailyVariant: SmartDailyVariant) async throws {
        guard dailyVariant.workoutID == value.id, dailyVariant.settingsRevision == value.smartSettings?.revision,
              dailyVariant.items == value.items else { throw PersistenceError.inconsistentDailyVariant }
        try saveAggregate(value, dailyVariant: dailyVariant)
    }

    private func saveAggregate(_ value: WorkoutSnapshot, dailyVariant: SmartDailyVariant?) throws {
        do {
            let id = value.id
            var descriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.id == id })
            descriptor.fetchLimit = 1
            let model = try context.fetch(descriptor).first ?? Workout()
            if model.modelContext == nil { context.insert(model) }
            try saveSettings(value.smartSettings, workoutID: value.id)
            if let dailyVariant { try saveDailyVariant(dailyVariant) }
            model.id = value.id
            model.name = value.name
            model.mode = value.mode
            model.targetMuscleGroups = value.targetMuscleGroups
            model.scheduledDays = value.scheduledDays
            model.durationMinutes = value.durationMinutes
            model.restSeconds = value.restSeconds
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

    private func saveDailyVariant(_ variant: SmartDailyVariant) throws {
        let key = variant.id
        var descriptor = FetchDescriptor<SmartDailyVariantRecord>(predicate: #Predicate { $0.key == key })
        descriptor.fetchLimit = 1
        let record = try context.fetch(descriptor).first ?? SmartDailyVariantRecord()
        if record.modelContext == nil { context.insert(record) }
        record.key = key
        record.workoutID = variant.workoutID
        record.localDay = variant.localDay
        record.settingsRevision = variant.settingsRevision
        record.createdAt = variant.createdAt
        record.payload = try JSONEncoder().encode(variant)
    }

    private func snapshot(_ model: Workout) throws -> WorkoutSnapshot {
        var result = model.snapshot()
        let id = model.id
        var descriptor = FetchDescriptor<SmartWorkoutSettingsRecord>(predicate: #Predicate { $0.workoutID == id })
        descriptor.fetchLimit = 1
        if let record = try context.fetch(descriptor).first {
            result.smartSettings = try JSONDecoder().decode(SmartWorkoutSettings.self, from: record.payload)
        }
        return result
    }

    private func saveSettings(_ settings: SmartWorkoutSettings?, workoutID: UUID) throws {
        var descriptor = FetchDescriptor<SmartWorkoutSettingsRecord>(predicate: #Predicate { $0.workoutID == workoutID })
        descriptor.fetchLimit = 1
        let existing = try context.fetch(descriptor).first
        guard let settings else {
            if let existing { context.delete(existing) }
            return
        }
        let record = existing ?? SmartWorkoutSettingsRecord()
        if record.modelContext == nil { context.insert(record) }
        record.workoutID = workoutID
        record.payload = try JSONEncoder().encode(settings)
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
