import Observation

/// Shared workout preferences, with persistence supplied by the composition root.
@MainActor
@Observable
final class WorkoutPreferences {
    var isTimerSoundEnabled: Bool {
        didSet {
            guard isTimerSoundEnabled != oldValue else { return }
            saveTimerSound(isTimerSoundEnabled)
        }
    }

    private let saveTimerSound: @MainActor (Bool) -> Void

    init(isTimerSoundEnabled: Bool = true, saveTimerSound: @escaping @MainActor (Bool) -> Void = { _ in }) {
        self.isTimerSoundEnabled = isTimerSoundEnabled
        self.saveTimerSound = saveTimerSound
    }
}
