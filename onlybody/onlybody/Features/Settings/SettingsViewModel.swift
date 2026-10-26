import Foundation
import Observation

/// Product information and editable preferences for the shared settings screen.
@MainActor
@Observable
final class SettingsViewModel {
    let appName: String
    let version: String
    let privacyPolicyURL = URL(string: "https://onlybody.app/privacy/")
    let termsOfUseURL = URL(string: "https://onlybody.app/terms/")
    private let preferences: WorkoutPreferences
    let weightUnits = WeightUnit.allCases

    var weightUnit: WeightUnit {
        get { preferences.weightUnit }
        set { preferences.weightUnit = newValue }
    }

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
