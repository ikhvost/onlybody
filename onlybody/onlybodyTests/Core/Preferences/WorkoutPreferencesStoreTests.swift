import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutPreferencesStoreTests {
    @Test func remindersPersistTimeIndependentlyOfEnabledAndTimerSound() throws {
        let suite = "WorkoutPreferencesTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = WorkoutPreferencesStore(defaults: defaults)
        let preferences = store.makePreferences()
        #expect(!preferences.areWorkoutRemindersEnabled)
        #expect(preferences.workoutReminderTime.label == "13:00")
        preferences.areWorkoutRemindersEnabled = true
        preferences.workoutReminderTime = WorkoutReminderTime(minutes: 810)
        #expect(store.makePreferences().areWorkoutRemindersEnabled)
        preferences.areWorkoutRemindersEnabled = false
        let reloaded = store.makePreferences()
        #expect(!reloaded.areWorkoutRemindersEnabled)
        #expect(reloaded.workoutReminderTime.label == "13:30")
        #expect(reloaded.isTimerSoundEnabled)
        defaults.set(1440, forKey: "workoutReminderMinutes")
        #expect(store.makePreferences().workoutReminderTime.label == "13:00")
    }

    @Test func reminderNamespacesStayIndependent() throws {
        let suite = "WorkoutPreferencesTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let isolated = WorkoutPreferencesStore(defaults: defaults, namespace: "UI-test").makePreferences()
        isolated.areWorkoutRemindersEnabled = true
        isolated.workoutReminderTime = WorkoutReminderTime(minutes: 0)
        for namespace in [nil, "Other-test"] as [String?] {
            let untouched = WorkoutPreferencesStore(defaults: defaults, namespace: namespace).makePreferences()
            #expect(!untouched.areWorkoutRemindersEnabled)
            #expect(untouched.workoutReminderTime.label == "13:00")
        }
        let restored = WorkoutPreferencesStore(defaults: defaults, namespace: "UI-test").makePreferences()
        #expect(restored.areWorkoutRemindersEnabled)
        #expect(restored.workoutReminderTime.label == "00:00")
    }

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
