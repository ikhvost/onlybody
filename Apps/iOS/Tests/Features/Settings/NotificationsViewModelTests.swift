import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct NotificationsViewModelTests {
    @Test func rapidWheelChangesSaveImmediatelyAndScheduleOnlyTheFinalSelection() async {
        let preferences = WorkoutPreferences(areWorkoutRemindersEnabled: true)
        let repository = MockWorkoutRepository()
        repository.stubbedWorkouts = [WorkoutSnapshot(scheduledDays: ["Sat"])]
        let client = MockWorkoutNotificationClient()
        let clock = ManualWorkoutTimeSource()
        let reminders = WorkoutReminderCoordinator(preferences: preferences, workouts: repository, notifications: client)
        let viewModel = NotificationsViewModel(preferences: preferences, reminders: reminders, time: clock)
        await viewModel.load()
        viewModel.selectedTime = WorkoutReminderTime(minutes: 795)
        await clock.waitForSleepers(1)
        viewModel.selectedTime = WorkoutReminderTime(minutes: 810)
        for _ in 0..<100 { await Task.yield() }
        #expect(preferences.workoutReminderTime.minutes == 810)
        #expect(client.additions == 1)
        clock.advance(seconds: 0.25)
        for _ in 0..<1_000 where client.additions < 2 { await Task.yield() }
        #expect(client.additions == 2)
        #expect(client.pending.values.first?.time.label == "13:30")
    }

    @Test func emptyScheduleAndTimeSelectionSurviveDisabling() async {
        let preferences = WorkoutPreferences()
        let reminders = WorkoutReminderCoordinator(
            preferences: preferences, workouts: MockWorkoutRepository(), notifications: MockWorkoutNotificationClient()
        )
        let viewModel = NotificationsViewModel(preferences: preferences, reminders: reminders)
        await viewModel.load()
        #expect(!viewModel.isEnabled)
        #expect(!viewModel.hasNoScheduledDays)
        await viewModel.setEnabled(true)
        #expect(viewModel.hasNoScheduledDays)
        viewModel.selectedTime = WorkoutReminderTime(minutes: 1425)
        await viewModel.setEnabled(false)
        #expect(!viewModel.hasNoScheduledDays)
        await viewModel.setEnabled(true)
        #expect(viewModel.selectedTime.label == "23:45")
        #expect(preferences.workoutReminderTime.minutes == 1425)
        #expect(preferences.isTimerSoundEnabled)
    }

    @Test func deniedPermissionAndSystemSettingsFailureAreRecoverable() async {
        let preferences = WorkoutPreferences()
        let client = MockWorkoutNotificationClient()
        client.status = .denied
        let reminders = WorkoutReminderCoordinator(
            preferences: preferences, workouts: MockWorkoutRepository(), notifications: client
        )
        var openAttempts = 0
        let viewModel = NotificationsViewModel(
            preferences: preferences, reminders: reminders, openSystemSettings: {
                openAttempts += 1
                return openAttempts > 1
            }
        )
        await viewModel.setEnabled(true)
        #expect(!viewModel.isEnabled)
        #expect(viewModel.isPermissionDenied)
        #expect(openAttempts == 1)
        #expect(client.authorizationRequests == 0)
        #expect(viewModel.errorMessage != nil)
        await viewModel.retry()
        #expect(openAttempts == 2)
        #expect(viewModel.errorMessage == nil)
        client.status = .authorized
        await viewModel.load()
        #expect(!viewModel.isPermissionDenied)
        #expect(viewModel.isEnabled)
    }

    @Test(arguments: [true, false])
    func firstPermissionRequestNeverOpensSettings(granted: Bool) async {
        let preferences = WorkoutPreferences()
        let client = MockWorkoutNotificationClient()
        client.status = .notDetermined
        client.grantsPermission = granted
        let reminders = WorkoutReminderCoordinator(
            preferences: preferences, workouts: MockWorkoutRepository(), notifications: client
        )
        var openAttempts = 0
        let viewModel = NotificationsViewModel(
            preferences: preferences, reminders: reminders, openSystemSettings: {
                openAttempts += 1
                return true
            }
        )
        await viewModel.load()
        #expect(client.authorizationRequests == 0)
        await viewModel.setEnabled(true)
        #expect(client.authorizationRequests == 1)
        #expect(viewModel.isEnabled == granted)
        #expect(openAttempts == 0)
    }

    @Test(arguments: [true, false])
    func settingsReturnConsumesOnlyTheExplicitEnableIntent(granted: Bool) async {
        let preferences = WorkoutPreferences(workoutReminderTime: WorkoutReminderTime(minutes: 810))
        let client = MockWorkoutNotificationClient()
        let repository = MockWorkoutRepository()
        repository.stubbedWorkouts = [WorkoutSnapshot(scheduledDays: ["Sat"])]
        let reminders = WorkoutReminderCoordinator(preferences: preferences, workouts: repository, notifications: client)
        var openAttempts = 0
        let viewModel = NotificationsViewModel(
            preferences: preferences, reminders: reminders, openSystemSettings: {
                openAttempts += 1
                return true
            }
        )
        await viewModel.load()
        client.status = .denied
        await viewModel.setEnabled(true)
        #expect(openAttempts == 1)
        #expect(!viewModel.isEnabled)
        #expect(client.pending.isEmpty)
        client.status = granted ? .authorized : .denied
        await viewModel.load()
        #expect(viewModel.isEnabled == granted)
        #expect(client.pending.count == (granted ? 1 : 0))
        #expect(viewModel.selectedTime.label == "13:30")
        #expect(openAttempts == 1)

        client.status = .denied
        await viewModel.load()
        #expect(!viewModel.isEnabled)
        #expect(client.pending.isEmpty)
        client.status = .authorized
        await viewModel.load()
        #expect(!viewModel.isEnabled)
        #expect(openAttempts == 1)
        await viewModel.setEnabled(true)
        #expect(viewModel.isEnabled)
        await viewModel.setEnabled(false)
        #expect(client.pending.isEmpty)
        #expect(openAttempts == 1)
    }
}
