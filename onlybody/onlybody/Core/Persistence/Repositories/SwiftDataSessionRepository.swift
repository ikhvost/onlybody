import Foundation
import SwiftData

/// Maps detached values to a private context and commits each aggregate atomically.
@MainActor
final class SwiftDataSessionRepository: SessionRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        context.autosaveEnabled = false
    }

    func allSessions() async throws -> [SessionSnapshot] {
        let descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\Session.date, order: .reverse)])
        return try context.fetch(descriptor).map { $0.snapshot() }
    }

    func save(_ value: SessionSnapshot) async throws {
        do {
            let id = value.id
            var descriptor = FetchDescriptor<Session>(predicate: #Predicate { $0.id == id })
            descriptor.fetchLimit = 1
            let model = try context.fetch(descriptor).first ?? Session()
            if model.modelContext == nil { context.insert(model) }
            model.id = value.id
            model.date = value.date
            model.durationSeconds = value.durationSeconds
            model.workoutName = value.workoutName
            for item in model.items ?? [] { context.delete(item) }
            model.items = []
            for valueItem in value.items {
                let item = SessionItem()
                item.id = valueItem.id
                item.order = valueItem.order
                item.exerciseName = valueItem.exerciseName
                item.plannedSets = valueItem.plannedSets
                item.plannedReps = valueItem.plannedReps
                item.setReps = valueItem.setReps
                item.weightKg = valueItem.weightKg
                item.setWeightsKg = valueItem.setWeightsKg
                model.items?.append(item)
            }
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
