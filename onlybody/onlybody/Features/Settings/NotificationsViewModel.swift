import Foundation

import Observation

/// Notification screen state; all system interactions are injected.
@MainActor
@Observable
final class NotificationsViewModel {
    private let preferences: WorkoutPreferences
    private let reminders: WorkoutReminderCoordinator
    private let openSystemSettings: @MainActor () async -> Bool
    private let time: any WorkoutTimeSource
    private var timeUpdateTask: Task<Void, Never>?
    private var settingsOpenFailed = false
    private var shouldEnableAfterSettings = false
    private var isUpdatingEnabled = false

    let timeOptions = WorkoutReminderTime.options
    var isEnabled: Bool { preferences.areWorkoutRemindersEnabled }
    var isRequestingPermission: Bool { isUpdatingEnabled || reminders.isRequestingPermission }
    var isPermissionDenied: Bool { reminders.authorization == .denied }
    var hasNoScheduledDays: Bool {
        isEnabled && !reminders.isRefreshing && reminders.errorMessage == nil && !reminders.hasScheduledDays
    }
    var errorMessage: String? {
        settingsOpenFailed ? String(localized: .uiCouldNotOpenSystemSettingsPleaseTryAgain) : reminders.errorMessage
    }
    var selectedTime: WorkoutReminderTime {
        get { preferences.workoutReminderTime }
        set {
            guard newValue != preferences.workoutReminderTime else { return }
            preferences.workoutReminderTime = newValue
            timeUpdateTask?.cancel()
            timeUpdateTask = Task { [time, reminders] in
                do {
                    try await time.sleep(for: .milliseconds(250))
                    try Task.checkCancellation()
                    await reminders.refresh()
                } catch {
                    // A newer wheel selection replaces this pending update.
                }
            }
        }
    }

    init(
        preferences: WorkoutPreferences,
        reminders: WorkoutReminderCoordinator,
        time: any WorkoutTimeSource = SystemWorkoutTimeSource(),
        openSystemSettings: @escaping @MainActor () async -> Bool = { false }
    ) {
        self.preferences = preferences
        self.reminders = reminders
        self.time = time
        self.openSystemSettings = openSystemSettings
    }

    func load() async {
        timeUpdateTask?.cancel()
        await reminders.refresh()
        guard shouldEnableAfterSettings else { return }
        shouldEnableAfterSettings = false
        if reminders.authorization == .authorized { await reminders.setEnabled(true) }
    }
    func setEnabled(_ enabled: Bool) async {
        guard !isRequestingPermission else { return }
        isUpdatingEnabled = true
        defer { isUpdatingEnabled = false }
        timeUpdateTask?.cancel()
        settingsOpenFailed = false
        shouldEnableAfterSettings = false
        if enabled {
            await reminders.refresh()
            if isPermissionDenied {
                await openSettings()
                return
            }
        }
        await reminders.setEnabled(enabled)
    }
    private func openSettings() async {
        shouldEnableAfterSettings = true
        settingsOpenFailed = !(await openSystemSettings())
        if settingsOpenFailed { shouldEnableAfterSettings = false }
    }
    func retry() async {
        timeUpdateTask?.cancel()
        if settingsOpenFailed { await openSettings() } else { await reminders.retry() }
    }
}
