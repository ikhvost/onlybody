import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SettingsViewModelTests {
    @Test func changingWeightUnitPersistsOnceAndReopensWithTheSameSelection() {
        var saved: [WeightUnit] = []
        let preferences = WorkoutPreferences(saveWeightUnit: { saved.append($0) })
        let model = SettingsViewModel(appName: "Test", version: "1", preferences: preferences)
        #expect(model.weightUnit == .kilograms)
        #expect(model.weightUnits == [.kilograms, .pounds])
        model.weightUnit = .pounds
        model.weightUnit = .pounds
        let reopened = SettingsViewModel(appName: "Test", version: "1", preferences: preferences)
        #expect(reopened.weightUnit == .pounds)
        #expect(saved == [.pounds])
        reopened.weightUnit = .kilograms
        #expect(model.weightUnit == .kilograms)
        #expect(saved == [.pounds, .kilograms])
        #expect(preferences.isTimerSoundEnabled)
        #expect(!preferences.areWorkoutRemindersEnabled)
    }

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
