import Foundation

import Observation

/// Serializes schedule updates so an older request cannot overwrite newer preferences.
@MainActor
@Observable
final class WorkoutReminderCoordinator {
    private let preferences: WorkoutPreferences
    private let workouts: any WorkoutRepository
    private let notifications: any WorkoutNotificationClient
    private let planner = WorkoutReminderPlanner()
    private var revision = 0
    private var refreshTask: Task<Void, Never>?
    private var permissionRequestFailed = false

    private(set) var authorization: ReminderAuthorization = .notDetermined
    private(set) var isRequestingPermission = false
    private(set) var isRefreshing = false
    private(set) var hasScheduledDays = false
    private(set) var errorMessage: String?

    init(preferences: WorkoutPreferences, workouts: any WorkoutRepository, notifications: any WorkoutNotificationClient) {
        self.preferences = preferences
        self.workouts = workouts
        self.notifications = notifications
    }

    func setEnabled(_ enabled: Bool) async {
        guard !isRequestingPermission else { return }
        if !enabled {
            preferences.areWorkoutRemindersEnabled = false
            await refresh()
            return
        }

        isRequestingPermission = true
        defer { isRequestingPermission = false }
        do {
            let status = await notifications.authorizationStatus()
            let allowed: Bool
            if status == .notDetermined {
                allowed = try await notifications.requestAuthorization()
            } else {
                allowed = status == .authorized
            }
            preferences.areWorkoutRemindersEnabled = allowed
            await refresh()
        } catch {
            preferences.areWorkoutRemindersEnabled = false
            await refresh()
            permissionRequestFailed = true
            errorMessage = String(localized: .uiCouldNotRequestNotificationPermissionPleaseTryAgain)
        }
    }

    func retry() async {
        if permissionRequestFailed { await setEnabled(true) } else { await refresh() }
    }

    /// Refresh never throws: a notification failure must not undo a saved workout.
    func refresh() async {
        revision += 1
        if let refreshTask {
            await refreshTask.value
            return
        }
        let task = Task { await reconcileLatest() }
        refreshTask = task
        await task.value
    }

    private func reconcileLatest() async {
        isRefreshing = true
        defer {
            isRefreshing = false
            refreshTask = nil
        }
        while true {
            let currentRevision = revision
            await reconcile(revision: currentRevision)
            if currentRevision == revision { return }
        }
    }

    private func reconcile(revision currentRevision: Int) async {
        permissionRequestFailed = false
        errorMessage = nil
        await notifications.removePendingReminders()
        let status = await notifications.authorizationStatus()
        guard currentRevision == revision else { return }
        authorization = status
        if status != .authorized {
            preferences.areWorkoutRemindersEnabled = false
        }
        hasScheduledDays = false
        guard preferences.areWorkoutRemindersEnabled else { return }

        do {
            let savedWorkouts = try await workouts.allWorkouts()
            guard currentRevision == revision else { return }
            let requests = planner.requests(for: savedWorkouts, at: preferences.workoutReminderTime)
            hasScheduledDays = !requests.isEmpty
            for request in requests {
                guard currentRevision == revision else { return }
                try await notifications.add(request)
            }
        } catch {
            await notifications.removePendingReminders()
            guard currentRevision == revision else { return }
            errorMessage = String(localized: .uiRemindersCouldNotBeUpdatedPleaseTryAgain)
        }
    }
}
