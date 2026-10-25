import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutPreferencesStoreTests {
    @Test func timerSoundDefaultsOnAndSurvivesStoreRecreation() throws {
        let suite = "WorkoutPreferencesTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let preferences = WorkoutPreferencesStore(defaults: defaults).makePreferences()
        #expect(preferences.isTimerSoundEnabled)
        preferences.isTimerSoundEnabled = false
        let reloaded = WorkoutPreferencesStore(defaults: defaults).makePreferences()
        #expect(!reloaded.isTimerSoundEnabled)
        reloaded.isTimerSoundEnabled = true
        #expect(WorkoutPreferencesStore(defaults: defaults).makePreferences().isTimerSoundEnabled)
    }

    @Test func uiTestNamespaceDoesNotChangeAppPreferences() throws {
        let suite = "WorkoutPreferencesTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let isolated = WorkoutPreferencesStore(defaults: defaults, namespace: "UI-test").makePreferences()
        isolated.isTimerSoundEnabled = false
        #expect(WorkoutPreferencesStore(defaults: defaults).makePreferences().isTimerSoundEnabled)
        #expect(WorkoutPreferencesStore(defaults: defaults, namespace: "Other-test").makePreferences().isTimerSoundEnabled)
        #expect(!WorkoutPreferencesStore(defaults: defaults, namespace: "UI-test").makePreferences().isTimerSoundEnabled)
    }
}
