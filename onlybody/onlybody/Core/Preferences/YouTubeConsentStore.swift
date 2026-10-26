import Foundation

/// Keeps consent in each app's own sandbox; previews and tests can use isolated stores.
@MainActor
struct YouTubeConsentStore {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, namespace: String? = nil) {
        self.defaults = defaults
        key = namespace.map { "\($0).youtubeConsent" } ?? "youtubeConsent"
    }

    func makeConsent() -> YouTubeConsent {
        let record = defaults.dictionary(forKey: key)
        let grantedAt = record?["version"] as? Int == YouTubeConsent.policyVersion ? record?["grantedAt"] as? Date : nil
        return YouTubeConsent(grantedAt: grantedAt, save: { date in
            if let date {
                defaults.set(["version": YouTubeConsent.policyVersion, "grantedAt": date], forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        })
    }
}
