import AVFAudio
import OSLog

/// Plays the bundled set-start cue at the user's media volume, alongside other audio.
@MainActor
final class WorkoutCuePlayer: NSObject, AVAudioPlayerDelegate {
    private let soundURL: URL?
    private let session = AVAudioSession.sharedInstance()
    private let logger = Logger(subsystem: "WorkoutAudio", category: "RestCompletion")
    private var player: AVAudioPlayer?
    private var ownsAudioSession = false

    init(soundURL: URL? = Bundle.main.url(forResource: "rest-complete", withExtension: "wav")) {
        self.soundURL = soundURL
        super.init()
    }

    func play() {
        stop()
        guard let soundURL else {
            logger.error("The rest-completion sound is missing from the app bundle.")
            return
        }
        do {
            let nextPlayer = try AVAudioPlayer(contentsOf: soundURL)
            try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            try session.setActive(true)
            ownsAudioSession = true
            nextPlayer.delegate = self
            nextPlayer.volume = 1
            player = nextPlayer
            if !nextPlayer.play() {
                logger.error("Could not start the rest-completion sound.")
                stop()
            }
        } catch {
            logger.error("Could not play the rest-completion sound: \(error.localizedDescription)")
            stop()
        }
    }

    func stop() {
        player?.stop()
        player = nil
        guard ownsAudioSession else { return }
        ownsAudioSession = false
        do {
            try session.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            logger.error("Could not release the workout audio session: \(error.localizedDescription)")
        }
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let identifier = ObjectIdentifier(player)
        Task { @MainActor [weak self] in self?.finish(playerID: identifier) }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
        let identifier = ObjectIdentifier(player)
        Task { @MainActor [weak self] in self?.finish(playerID: identifier) }
    }

    private func finish(playerID: ObjectIdentifier) {
        guard let player, ObjectIdentifier(player) == playerID else { return }
        stop()
    }
}
