import Foundation
import Testing
@testable import onlybody

struct ExerciseDemonstrationTests {
    @Test func catalogHasUniqueStableKeysAndValidYouTubeLinks() throws {
        let all = ExerciseDemonstrationCatalog.all
        #expect(all.count == 49)
        #expect(Set(all.map(\.id)).count == all.count)
        #expect(Set(all.map(\.exerciseName)).count == all.count)
        for demonstration in all {
            #expect(demonstration.isValid)
            #expect(ExerciseDemonstrationCatalog.demonstration(for: demonstration.exerciseName) == demonstration)
            let url = try #require(demonstration.watchURL)
            let parts = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
            #expect(parts.scheme == "https")
            #expect(parts.host == "www.youtube.com")
            #expect(parts.queryItems?.first { $0.name == "v" }?.value == demonstration.videoID)
            #expect(parts.queryItems?.first { $0.name == "t" }?.value == "\(demonstration.startSeconds)s")
        }
        #expect(ExerciseDemonstrationCatalog.demonstration(for: "Unknown exercise") == nil)
    }

    @Test(arguments: ["", "too-short", "1234567890'", "</script>!!"])
    func invalidVideoIDsCannotProduceAURLOrEmbed(videoID: String) {
        let demonstration = ExerciseDemonstration(id: "test", exerciseName: "Test", videoID: videoID, author: "Author", startSeconds: 0)
        #expect(!demonstration.isValid)
        #expect(demonstration.watchURL == nil)
        #expect(YouTubeEmbedDocument(demonstration: demonstration, bundleIdentifier: "ikhvost.onlybody") == nil)
    }

    @Test func negativeOffsetIsRejected() {
        let demonstration = ExerciseDemonstration(id: "test", exerciseName: "Test", videoID: "12345678901", author: "Author", startSeconds: -1)
        #expect(!demonstration.isValid)
    }

    @Test func embedIdentifiesTheAppAndPreservesManualStandardPlayer() throws {
        let demonstration = try #require(ExerciseDemonstrationCatalog.demonstration(for: "Dead Bug"))
        let document = try #require(YouTubeEmbedDocument(demonstration: demonstration, bundleIdentifier: "Ikhvost.OnlyBody"))
        #expect(document.baseURL.absoluteString == "https://ikhvost.onlybody")
        #expect(document.html.contains("\"autoplay\":0"))
        #expect(document.html.contains("\"controls\":1"))
        #expect(document.html.contains("\"fs\":1"))
        #expect(document.html.contains("\"playsinline\":1"))
        #expect(document.html.contains("\"start\":8"))
        #expect(document.html.contains("strict-origin-when-cross-origin"))
        #expect(!document.html.contains("playVideo()"))
        #expect(YouTubeEmbedDocument(demonstration: demonstration, bundleIdentifier: "") == nil)
        #expect(YouTubeEmbedDocument(demonstration: demonstration, bundleIdentifier: "bad/id<script>") == nil)
    }

    @Test func playerErrorsHaveRecoverableExplanations() {
        #expect(DemonstrationFailure(playerError: 100) == .unavailable)
        #expect(DemonstrationFailure(playerError: 101) == .unavailable)
        #expect(DemonstrationFailure(playerError: 150) == .unavailable)
        #expect(DemonstrationFailure(playerError: 153) == .configuration)
        #expect(DemonstrationFailure(playerError: 2) == .configuration)
        #expect(DemonstrationFailure(playerError: 5) == .connection)
    }
}
