import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct YouTubeTrackingPermissionTests {
    private func movement(
        consent: YouTubeConsent = YouTubeConsent(),
        tracking: MockTrackingAuthorizationSource
    ) -> MovementDetailViewModel {
        MovementDetailViewModel(
            exercise: ExerciseSnapshot(),
            demonstration: ExerciseDemonstration(
                id: "test", exerciseName: "Test", videoID: "Yw9RPfBRjx0", author: "Author", startSeconds: 12
            ),
            bundleIdentifier: "ikhvost.onlybody",
            network: ManualNetworkAvailabilitySource(),
            youtubeConsent: consent,
            trackingAuthorization: tracking
        )
    }

    @Test(arguments: [TrackingPermission.notDetermined, .denied, .restricted])
    func localConsentCannotBypassSystemPermission(_ status: TrackingPermission) {
        let tracking = MockTrackingAuthorizationSource(status: status)
        let viewModel = movement(consent: YouTubeConsent(grantedAt: Date()), tracking: tracking)
        viewModel.prepareDemonstration()
        viewModel.allowYouTube()
        viewModel.loadDemonstration()
        viewModel.setPlayerActive(false)
        viewModel.setPlayerActive(true)
        #expect(viewModel.playerSessionID == nil)
        #expect(viewModel.playerTimeoutID == nil)
        #expect(viewModel.needsVideoPermission)
        #expect(tracking.requestCount == 0)
        #expect(viewModel.externalVideoURL?.absoluteString == "https://www.youtube.com/watch?v=Yw9RPfBRjx0&t=12s")
    }

    @Test func explicitAuthorizationEnablesPlayerAndRevocationRemovesIt() async throws {
        let tracking = MockTrackingAuthorizationSource(status: .notDetermined)
        let viewModel = movement(tracking: tracking)
        await viewModel.enableYouTubePlayback()
        let previousSession = try #require(viewModel.playerSessionID)
        #expect(tracking.requestCount == 1)
        #expect(!viewModel.needsVideoPermission)
        viewModel.setPlayerActive(false)
        tracking.status = .denied
        viewModel.setPlayerActive(true)
        #expect(viewModel.playerSessionID == nil)
        #expect(viewModel.playerTimeoutID == nil)
        #expect(!viewModel.canRequestVideoPermission)
        viewModel.receivePlayerEvent(.playing, sessionID: previousSession)
        #expect(viewModel.demonstrationState == .idle)
        #expect(viewModel.externalVideoURL != nil)
    }

    @Test func deniedRequestKeepsExternalPlaybackAvailable() async {
        let tracking = MockTrackingAuthorizationSource(status: .notDetermined)
        tracking.response = .denied
        let viewModel = movement(tracking: tracking)
        await viewModel.enableYouTubePlayback()
        #expect(viewModel.playerSessionID == nil)
        #expect(!viewModel.canRequestVideoPermission)
        #expect(!viewModel.isRequestingVideoPermission)
        #expect(viewModel.externalVideoURL != nil)
    }

    @Test func withdrawalWhilePromptIsPendingDoesNotRecreatePlayer() async throws {
        let consent = YouTubeConsent()
        let tracking = MockTrackingAuthorizationSource(status: .notDetermined)
        tracking.waitsForResponse = true
        let viewModel = movement(consent: consent, tracking: tracking)
        let task = Task { await viewModel.enableYouTubePlayback() }
        for _ in 0..<1_000 {
            if tracking.continuation != nil { break }
            await Task.yield()
        }
        _ = try #require(tracking.continuation)
        await viewModel.enableYouTubePlayback()
        #expect(tracking.requestCount == 1)
        consent.revoke()
        tracking.resolve(.authorized)
        await task.value
        #expect(viewModel.playerSessionID == nil)
        #expect(!consent.isAllowed)
        #expect(!viewModel.isRequestingVideoPermission)
    }
}
