import Foundation
import SwiftData

@MainActor
final class SwiftDataSessionRepository: SessionRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allSessions() async throws -> [Session] {
        let descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\Session.date, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func recentSessions(limit: Int) async throws -> [Session] {
        var descriptor = FetchDescriptor<Session>(sortBy: [SortDescriptor(\Session.date, order: .reverse)])
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    func save(_ session: Session) async throws {
        if session.modelContext == nil {
            context.insert(session)
        }

        try context.save()
    }
}
