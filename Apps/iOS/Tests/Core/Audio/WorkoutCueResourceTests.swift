import AVFAudio
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutCueResourceTests {
    @Test func bundledCueDecodesAsOneSecondOfMonoAudio() throws {
        let bundle = Bundle(for: WorkoutCuePlayer.self)
        let url = try #require(bundle.url(forResource: "rest-complete", withExtension: "wav"))
        let player = try AVAudioPlayer(contentsOf: url)
        #expect(abs(player.duration - 1) < 0.01)
        #expect(player.numberOfChannels == 1)
    }
}
