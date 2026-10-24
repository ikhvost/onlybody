import Foundation
@testable import onlybody

@MainActor
final class MockSessionRepository: SessionRepository {
    var stubbedSessions: [SessionSnapshot] = []
    var shouldThrow = false
    var suspendSaves = false
    private var saveContinuation: CheckedContinuation<Void, Never>?
    var isWaitingToSave: Bool { saveContinuation != nil }

    func resumeSave() {
        saveContinuation?.resume()
        saveContinuation = nil
    }
    var savedSessions: [SessionSnapshot] = []

    func allSessions() async throws -> [SessionSnapshot] {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        return stubbedSessions
    }

    func save(_ session: SessionSnapshot) async throws {
        if shouldThrow {
            throw TestError.expectedFailure
        }
        if suspendSaves {
            await withCheckedContinuation { saveContinuation = $0 }
        }
        savedSessions.append(session)
    }
}
