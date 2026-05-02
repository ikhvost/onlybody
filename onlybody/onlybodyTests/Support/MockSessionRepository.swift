import Foundation
@testable import onlybody

@MainActor
final class MockSessionRepository: SessionRepository {
    var stubbedSessions: [Session] = []
    var shouldThrow = false
    var savedSessions: [Session] = []

    func allSessions() async throws -> [Session] {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        return stubbedSessions
    }

    func recentSessions(limit: Int) async throws -> [Session] {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        return Array(stubbedSessions.prefix(limit))
    }

    func save(_ session: Session) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        savedSessions.append(session)
    }
}
