import Observation

/// Product information and editable preferences for the shared settings screen.
@MainActor
@Observable
final class SettingsViewModel {
    let appName: String
    let version: String
    private let preferences: WorkoutPreferences

    var isTimerSoundEnabled: Bool {
        get { preferences.isTimerSoundEnabled }
        set { preferences.isTimerSoundEnabled = newValue }
    }

    init(appName: String, version: String, preferences: WorkoutPreferences = WorkoutPreferences()) {
        self.appName = appName
        self.version = version
        self.preferences = preferences
    }
}
