import Foundation

/// Stores preferences in the product's local defaults, isolated by namespace during UI tests.
@MainActor
struct WorkoutPreferencesStore {
    private let defaults: UserDefaults
    private let timerSoundKey: String

    init(defaults: UserDefaults = .standard, namespace: String? = nil) {
        self.defaults = defaults
        timerSoundKey = namespace.map { "\($0).timerSoundEnabled" } ?? "timerSoundEnabled"
    }

    func makePreferences() -> WorkoutPreferences {
        WorkoutPreferences(
            isTimerSoundEnabled: defaults.object(forKey: timerSoundKey) as? Bool ?? true,
            saveTimerSound: { defaults.set($0, forKey: timerSoundKey) }
        )
    }
}
