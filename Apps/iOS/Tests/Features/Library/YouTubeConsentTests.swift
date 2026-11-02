import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct YouTubeConsentTests {
    private func movement(
        consent: YouTubeConsent, network: any NetworkAvailabilitySource = ManualNetworkAvailabilitySource()
    ) -> MovementDetailViewModel {
        MovementDetailViewModel(
            exercise: ExerciseSnapshot(),
            demonstration: ExerciseDemonstration(
                id: "test", exerciseName: "Test", videoID: "Yw9RPfBRjx0", author: "Author", startSeconds: 0
            ),
            bundleIdentifier: "ikhvost.onlybody",
            network: network,
            youtubeConsent: consent,
            trackingAuthorization: MockTrackingAuthorizationSource()
        )
    }

    @Test func noPlayerUntilPermissionEvenOnRetryAndForeground() {
        let viewModel = movement(consent: YouTubeConsent())
        viewModel.prepareDemonstration()
        viewModel.loadDemonstration()
        viewModel.setPlayerActive(false)
        viewModel.setPlayerActive(true)
        #expect(viewModel.needsYouTubeConsent)
        #expect(viewModel.playerSessionID == nil)
        #expect(viewModel.playerTimeoutID == nil)
        viewModel.allowYouTube()
        #expect(!viewModel.needsYouTubeConsent)
        #expect(viewModel.playerSessionID != nil)
        #expect(viewModel.demonstrationState == .loading)
    }

    @Test func settingsRevocationInvalidatesEveryPlayerAndStaleCallbacks() throws {
        let consent = YouTubeConsent()
        let first = movement(consent: consent)
        let second = movement(consent: consent)
        first.allowYouTube()
        second.prepareDemonstration()
        let oldSession = try #require(first.playerSessionID)
        let settings = SettingsViewModel(appName: "Test", version: "1", youtubeConsent: consent)
        #expect(settings.areYouTubeVideosAllowed)
        settings.revokeYouTubeConsent()
        #expect(first.playerSessionID == nil)
        #expect(second.playerSessionID == nil)
        first.refreshYouTubeConsent()
        first.receivePlayerEvent(.playing, sessionID: oldSession)
        first.loadDemonstration()
        #expect(first.demonstrationState == .idle)
        #expect(first.playerTimeoutID == nil)
        first.allowYouTube()
        #expect(first.playerSessionID != oldSession)
        #expect(second.playerSessionID == nil)
        first.receivePlayerEvent(.failed(.connection), sessionID: oldSession)
        #expect(first.demonstrationState == .loading)
    }

    @Test func offlinePermissionAndReconnectRespectWithdrawal() async throws {
        let consent = YouTubeConsent()
        let network = ManualNetworkAvailabilitySource()
        let viewModel = movement(consent: consent, network: network)
        let task = Task { await viewModel.monitorDemonstrationConnection() }
        defer { task.cancel() }
        for _ in 0..<1_000 {
            if network.continuation != nil { break }
            await Task.yield()
        }
        let continuation = try #require(network.continuation)
        continuation.yield(false)
        continuation.finish()
        await task.value
        viewModel.allowYouTube()
        #expect(viewModel.demonstrationState == .offline)
        #expect(viewModel.playerSessionID == nil)
        consent.revoke()
        viewModel.refreshYouTubeConsent()
        var reconnectStarted = false
        let reconnect = Task {
            reconnectStarted = true
            await viewModel.monitorDemonstrationConnection()
        }
        for _ in 0..<1_000 {
            if reconnectStarted { break }
            await Task.yield()
        }
        #expect(reconnectStarted)
        network.continuation?.yield(true)
        network.continuation?.finish()
        await reconnect.value
        #expect(viewModel.playerSessionID == nil)
        #expect(viewModel.needsYouTubeConsent)
        #expect(viewModel.demonstrationState == .idle)
    }

    @Test func consentPersistsAndRevokesWithoutCrossingProductNamespaces() throws {
        let suite = "YouTubeConsentTests.\(UUID())"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let bodyStore = YouTubeConsentStore(defaults: defaults, namespace: "body")
        let weightsStore = YouTubeConsentStore(defaults: defaults, namespace: "weights")
        let consent = bodyStore.makeConsent()
        #expect(!consent.isAllowed)
        consent.allow()
        #expect(bodyStore.makeConsent().grantedAt == consent.grantedAt)
        #expect(!weightsStore.makeConsent().isAllowed)
        consent.revoke()
        #expect(!bodyStore.makeConsent().isAllowed)
        defaults.set(["version": 1, "grantedAt": Date()], forKey: "body.youtubeConsent")
        #expect(!bodyStore.makeConsent().isAllowed)
    }
}
