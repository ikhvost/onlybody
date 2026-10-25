import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SettingsViewModelTests {
    @Test func changingTimerSoundPersistsAndIsVisibleWhenSettingsReopen() {
        var savedValues: [Bool] = []
        let preferences = WorkoutPreferences(saveTimerSound: { savedValues.append($0) })
        let model = SettingsViewModel(appName: "Test", version: "1", preferences: preferences)
        #expect(model.isTimerSoundEnabled)
        #expect(savedValues.isEmpty)
        model.isTimerSoundEnabled = false
        model.isTimerSoundEnabled = false
        let reopened = SettingsViewModel(appName: "Test", version: "1", preferences: preferences)
        #expect(!reopened.isTimerSoundEnabled)
        #expect(savedValues == [false])
        reopened.isTimerSoundEnabled = true
        #expect(model.isTimerSoundEnabled)
        #expect(savedValues == [false, true])
    }
}
