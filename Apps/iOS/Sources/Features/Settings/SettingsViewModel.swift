import Foundation
import Observation

/// Product information and editable preferences for the shared settings screen.
@MainActor
@Observable
final class SettingsViewModel {
    let appName: String
    let version: String
    let appStoreReviewURL: URL?
    let privacyPolicyURL = URL(string: "https://onlybody.app/privacy/")
    let termsOfUseURL = URL(string: "https://onlybody.app/terms/")
    private let preferences: WorkoutPreferences
    private let restAlertAuthorization: @MainActor () async -> ReminderAuthorization
    private let openNotificationSettings: @MainActor () async -> Void
    private var restAlertsUnavailable = false
    let weightUnits = WeightUnit.allCases

    var feedbackURL: URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "support@onlybody.app"
        components.queryItems = [URLQueryItem(name: "subject", value: "\(appName) feedback")]
        return components.url
    }

    var weightUnit: WeightUnit {
        get { preferences.weightUnit }
        set { preferences.weightUnit = newValue }
    }

    var isTimerSoundEnabled: Bool {
        get { preferences.isTimerSoundEnabled }
        set { preferences.isTimerSoundEnabled = newValue }
    }

    var showsRestAlertSettings: Bool { isTimerSoundEnabled && restAlertsUnavailable }

    func refreshRestAlertStatus() async {
        restAlertsUnavailable = await restAlertAuthorization() == .denied
    }

    func showNotificationSettings() async { await openNotificationSettings() }

    init(
        appName: String,
        version: String,
        appStoreReviewURL: URL? = nil,
        preferences: WorkoutPreferences = WorkoutPreferences(),
        restAlertAuthorization: @escaping @MainActor () async -> ReminderAuthorization = { .notDetermined },
        openNotificationSettings: @escaping @MainActor () async -> Void = {}
    ) {
        self.appName = appName
        self.version = version
        self.appStoreReviewURL = appStoreReviewURL
        self.preferences = preferences
        self.restAlertAuthorization = restAlertAuthorization
        self.openNotificationSettings = openNotificationSettings
    }
}
