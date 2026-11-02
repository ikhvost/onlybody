import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutReminderCoordinatorTests {
    @Test func startupDoesNotRequestPermissionAndEnablingDoes() async {
        let preferences = WorkoutPreferences()
        let repository = MockWorkoutRepository()
        repository.stubbedWorkouts = [WorkoutSnapshot(scheduledDays: ["Mon", "Sat"])]
        let client = MockWorkoutNotificationClient()
        client.status = .notDetermined
        let coordinator = WorkoutReminderCoordinator(preferences: preferences, workouts: repository, notifications: client)
        await coordinator.refresh()
        #expect(!preferences.areWorkoutRemindersEnabled)
        #expect(client.authorizationRequests == 0)
        #expect(client.pending.isEmpty)
        await coordinator.setEnabled(true)
        #expect(client.authorizationRequests == 1)
        #expect(preferences.areWorkoutRemindersEnabled)
        #expect(client.pending.count == 2)
        #expect(coordinator.hasScheduledDays)
        #expect(client.pending.values.allSatisfy { $0.time.label == "13:00" })
    }

    @Test func refusalAndRevocationDisableRemindersAndRequireExplicitReenable() async {
        let preferences = WorkoutPreferences()
        let repository = MockWorkoutRepository()
        repository.stubbedWorkouts = [WorkoutSnapshot(scheduledDays: ["Fri"])]
        let client = MockWorkoutNotificationClient()
        client.status = .notDetermined
        client.grantsPermission = false
        let coordinator = WorkoutReminderCoordinator(preferences: preferences, workouts: repository, notifications: client)
        await coordinator.setEnabled(true)
        #expect(coordinator.authorization == .denied)
        #expect(!preferences.areWorkoutRemindersEnabled)
        await coordinator.setEnabled(true)
        #expect(client.authorizationRequests == 1)
        client.status = .authorized
        await coordinator.refresh()
        #expect(!preferences.areWorkoutRemindersEnabled)
        await coordinator.setEnabled(true)
        #expect(client.pending.count == 1)
        client.status = .denied
        await coordinator.refresh()
        #expect(!preferences.areWorkoutRemindersEnabled)
        #expect(client.pending.isEmpty)
    }

    @Test func editsDeletionAndDisableReplaceTheScheduleAndKeepTime() async {
        let preferences = WorkoutPreferences(areWorkoutRemindersEnabled: true, workoutReminderTime: WorkoutReminderTime(minutes: 1410))
        let repository = MockWorkoutRepository()
        repository.stubbedWorkouts = [WorkoutSnapshot(scheduledDays: ["Mon", "Fri"])]
        let client = MockWorkoutNotificationClient()
        let coordinator = WorkoutReminderCoordinator(preferences: preferences, workouts: repository, notifications: client)
        await coordinator.refresh()
        #expect(client.pending.count == 2)
        repository.stubbedWorkouts[0].scheduledDays = ["Sat"]
        await coordinator.refresh()
        #expect(client.pending.values.map(\.weekday) == [7])
        await coordinator.setEnabled(false)
        #expect(client.pending.isEmpty)
        #expect(preferences.workoutReminderTime.label == "23:30")
        await coordinator.setEnabled(true)
        #expect(client.pending.values.first?.time.label == "23:30")
        repository.stubbedWorkouts = []
        await coordinator.refresh()
        #expect(preferences.areWorkoutRemindersEnabled)
        #expect(!coordinator.hasScheduledDays)
        #expect(client.pending.isEmpty)
    }

    @Test func partialFailureIsClearedAndRetryUsesSavedPreferences() async {
        let preferences = WorkoutPreferences(areWorkoutRemindersEnabled: true)
        let repository = MockWorkoutRepository()
        repository.stubbedWorkouts = [WorkoutSnapshot(scheduledDays: ["Mon", "Wed"])]
        let client = MockWorkoutNotificationClient()
        client.failOnAdd = 2
        let coordinator = WorkoutReminderCoordinator(preferences: preferences, workouts: repository, notifications: client)
        await coordinator.refresh()
        #expect(client.pending.isEmpty)
        #expect(coordinator.errorMessage != nil)
        #expect(preferences.areWorkoutRemindersEnabled)
        client.failOnAdd = nil
        await coordinator.retry()
        #expect(client.pending.count == 2)
        #expect(coordinator.errorMessage == nil)
        repository.shouldThrow = true
        await coordinator.refresh()
        #expect(client.pending.isEmpty)
        #expect(coordinator.errorMessage != nil)
    }

    @Test func permissionRequestFailureCanBeRetried() async {
        let client = MockWorkoutNotificationClient()
        client.status = .notDetermined
        client.requestShouldThrow = true
        let preferences = WorkoutPreferences()
        let coordinator = WorkoutReminderCoordinator(preferences: preferences, workouts: MockWorkoutRepository(), notifications: client)
        await coordinator.setEnabled(true)
        #expect(!preferences.areWorkoutRemindersEnabled)
        #expect(coordinator.errorMessage != nil)
        client.requestShouldThrow = false
        await coordinator.retry()
        #expect(preferences.areWorkoutRemindersEnabled)
        #expect(client.authorizationRequests == 2)
        #expect(coordinator.errorMessage == nil)
    }

    @Test func latestTimeWinsWhileAnEarlierSystemWriteIsSuspended() async {
        let preferences = WorkoutPreferences(areWorkoutRemindersEnabled: true)
        let repository = MockWorkoutRepository()
        repository.stubbedWorkouts = [WorkoutSnapshot(scheduledDays: ["Mon", "Tue"])]
        let client = MockWorkoutNotificationClient()
        client.suspendNextAdd = true
        let coordinator = WorkoutReminderCoordinator(preferences: preferences, workouts: repository, notifications: client)
        let original = Task { await coordinator.refresh() }
        for _ in 0..<1_000 where !client.isWaitingForAdd { await Task.yield() }
        #expect(client.isWaitingForAdd)
        preferences.workoutReminderTime = WorkoutReminderTime(minutes: 795)
        let firstEdit = Task { await coordinator.refresh() }
        for _ in 0..<100 { await Task.yield() }
        preferences.workoutReminderTime = WorkoutReminderTime(minutes: 810)
        let finalEdit = Task { await coordinator.refresh() }
        for _ in 0..<100 { await Task.yield() }
        client.resumeAdd()
        await original.value
        await firstEdit.value
        await finalEdit.value
        #expect(client.pending.count == 2)
        #expect(client.pending.values.allSatisfy { $0.time.label == "13:30" })
        #expect(!coordinator.isRefreshing)
    }

    @Test func disablingDuringAnInFlightWriteLeavesNoPendingReminders() async {
        let preferences = WorkoutPreferences(areWorkoutRemindersEnabled: true)
        let repository = MockWorkoutRepository()
        repository.stubbedWorkouts = [WorkoutSnapshot(scheduledDays: ["Mon"])]
        let client = MockWorkoutNotificationClient()
        client.suspendNextAdd = true
        let coordinator = WorkoutReminderCoordinator(preferences: preferences, workouts: repository, notifications: client)
        let original = Task { await coordinator.refresh() }
        for _ in 0..<1_000 where !client.isWaitingForAdd { await Task.yield() }
        let disable = Task { await coordinator.setEnabled(false) }
        for _ in 0..<100 { await Task.yield() }
        client.resumeAdd()
        await original.value
        await disable.value
        #expect(client.pending.isEmpty)
        #expect(!preferences.areWorkoutRemindersEnabled)
    }

    @Test func repeatedEnableDoesNotPresentMultiplePermissionPrompts() async {
        let client = MockWorkoutNotificationClient()
        client.status = .notDetermined
        client.suspendPermissionRequest = true
        let coordinator = WorkoutReminderCoordinator(
            preferences: WorkoutPreferences(), workouts: MockWorkoutRepository(), notifications: client
        )
        let enable = Task { await coordinator.setEnabled(true) }
        for _ in 0..<1_000 where !client.isWaitingForPermission { await Task.yield() }
        #expect(coordinator.isRequestingPermission)
        await coordinator.setEnabled(true)
        #expect(client.authorizationRequests == 1)
        client.resumePermission()
        await enable.value
        #expect(!coordinator.isRequestingPermission)
    }
}
