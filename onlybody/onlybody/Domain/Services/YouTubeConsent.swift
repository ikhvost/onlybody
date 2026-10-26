import Foundation
import Observation

/// Product-local permission to contact YouTube, with versioned consent persisted at app entry.
@MainActor
@Observable
final class YouTubeConsent {
    static let policyVersion = 1
    private(set) var revision = UUID()
    private(set) var grantedAt: Date?
    private let save: (Date?) -> Void
    private let now: () -> Date

    var isAllowed: Bool { grantedAt != nil }

    init(grantedAt: Date? = nil, now: @escaping () -> Date = Date.init, save: @escaping (Date?) -> Void = { _ in }) {
        self.grantedAt = grantedAt
        self.now = now
        self.save = save
    }

    func allow() {
        guard !isAllowed else { return }
        revision = UUID()
        grantedAt = now()
        save(grantedAt)
    }

    func revoke() {
        revision = UUID()
        grantedAt = nil
        save(nil)
    }
}
