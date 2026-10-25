import Foundation

/// Stores preferences in the product's local defaults, isolated by namespace during UI tests.
@MainActor
struct WorkoutPreferencesStore {
    private let defaults: UserDefaults
    private let timerSoundKey: String
    private let remindersEnabledKey: String
    private let reminderTimeKey: String

    init(defaults: UserDefaults = .standard, namespace: String? = nil) {
        self.defaults = defaults
        timerSoundKey = namespace.map { "\($0).timerSoundEnabled" } ?? "timerSoundEnabled"
        remindersEnabledKey = namespace.map { "\($0).workoutRemindersEnabled" } ?? "workoutRemindersEnabled"
        reminderTimeKey = namespace.map { "\($0).workoutReminderMinutes" } ?? "workoutReminderMinutes"
    }

    func makePreferences() -> WorkoutPreferences {
        WorkoutPreferences(
            isTimerSoundEnabled: defaults.object(forKey: timerSoundKey) as? Bool ?? true,
            saveTimerSound: { defaults.set($0, forKey: timerSoundKey) },
            areWorkoutRemindersEnabled: defaults.bool(forKey: remindersEnabledKey),
            workoutReminderTime: WorkoutReminderTime(
                minutes: defaults.object(forKey: reminderTimeKey) as? Int ?? WorkoutReminderTime.defaultMinutes
            ),
            saveRemindersEnabled: { defaults.set($0, forKey: remindersEnabledKey) },
            saveReminderTime: { defaults.set($0.minutes, forKey: reminderTimeKey) }
        )
    }
}
