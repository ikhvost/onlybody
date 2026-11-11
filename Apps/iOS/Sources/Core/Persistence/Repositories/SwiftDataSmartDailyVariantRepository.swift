import Foundation
import SwiftData

/// Private-context, single-save writes with rollback; snapshot payloads have no live model references.
@MainActor
final class SwiftDataSmartDailyVariantRepository: SmartDailyVariantRepository {
    private let context: ModelContext
    init(context: ModelContext) {
        self.context = context
        context.autosaveEnabled = false
    }

    func variant(workoutID: UUID, localDay: String, settingsRevision: UUID) async throws -> SmartDailyVariant? {
        var descriptor = FetchDescriptor<SmartDailyVariantRecord>(predicate: #Predicate {
            $0.workoutID == workoutID && $0.localDay == localDay && $0.settingsRevision == settingsRevision
        })
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return nil }
        return try JSONDecoder().decode(SmartDailyVariant.self, from: record.payload)
    }

    func latestVariant(workoutID: UUID) async throws -> SmartDailyVariant? {
        var descriptor = FetchDescriptor<SmartDailyVariantRecord>(predicate: #Predicate { $0.workoutID == workoutID },
                                                                 sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        descriptor.fetchLimit = 1
        guard let record = try context.fetch(descriptor).first else { return nil }
        return try JSONDecoder().decode(SmartDailyVariant.self, from: record.payload)
    }

    func save(_ variant: SmartDailyVariant) async throws {
        do {
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
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
