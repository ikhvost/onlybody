import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct YouTubeIntegrationTests {
    @Test func hostedAppUsesItsOwnIdentityForYouTube() throws {
        #if ONLYWEIGHTS
        let expectedIdentity = "ikhvost.onlyweights"
        #else
        let expectedIdentity = "ikhvost.onlybody"
        #endif
        let identity = try #require(Bundle.main.bundleIdentifier)
        #expect(identity == expectedIdentity)
        let demonstration = ExerciseDemonstration(
            id: "test", exerciseName: "Test", videoID: "Yw9RPfBRjx0", author: "Test author", startSeconds: 0
        )
        let document = try #require(YouTubeEmbedDocument(demonstration: demonstration, bundleIdentifier: identity))
        #expect(document.baseURL.absoluteString == "https://\(expectedIdentity)")
        #expect(document.html.contains("\"origin\":\"https:\\/\\/\(expectedIdentity)\""))
        #expect(document.html.contains("strict-origin-when-cross-origin"))
        #expect(document.html.contains("https://www.youtube.com/iframe_api"))
        #expect(document.html.contains("\"controls\":1"))
    }

    @Test func playerMeetsMinimumViewportDimensions() {
        #expect(Theme.demonstrationMinimumWidth >= 200)
        #expect(Theme.demonstrationHeight >= 200)
    }

    @Test func unavailableAndUnidentifiedPlayersFailRecoverably() {
        for code in [100, 101, 150] {
            #expect(DemonstrationFailure(playerError: code) == .unavailable)
        }
        #expect(DemonstrationFailure(playerError: 153) == .configuration)
    }
}
