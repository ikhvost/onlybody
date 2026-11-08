import UserNotifications

/// Routes both kinds of workout notifications through the app's single system delegate.
@MainActor
final class SystemWorkoutNotificationClient: NSObject, WorkoutNotificationClient, WorkoutRestNotificationClient,
    UNUserNotificationCenterDelegate {
    private let center: UNUserNotificationCenter
    weak var restAlerts: WorkoutRestAlerts?

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
        super.init()
        center.delegate = self
    }

    func authorizationStatus() async -> ReminderAuthorization {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .authorized, .provisional, .ephemeral: return .authorized
        @unknown default: return .denied
        }
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }

    func removePendingReminders() async {
        center.removePendingNotificationRequests(withIdentifiers: WorkoutReminderRequest.identifiers)
    }

    func add(_ request: WorkoutReminderRequest) async throws {
        try await center.add(Self.notificationRequest(for: request))
    }

    func restAlertAuthorization() async -> ReminderAuthorization {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .authorized, .ephemeral: return settings.soundSetting == .enabled ? .authorized : .denied
        default: return .denied
        }
    }

    func scheduleRestAlert(id: String, deadline: Date) async throws -> Bool {
        guard let request = Self.restNotificationRequest(id: id, deadline: deadline, now: .now) else { return false }
        try await center.add(request)
        return true
    }

    func removeRestAlert(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.removeDeliveredNotifications(withIdentifiers: [id])
    }

    func removeAbandonedRestAlerts() async {
        let pending = await center.pendingNotificationRequests().map(\.identifier)
        let delivered = await center.deliveredNotifications().map(\.request.identifier)
        for id in Set(pending + delivered)
            where id.hasPrefix(WorkoutRestAlerts.requestPrefix) && id != restAlerts?.notificationID {
            removeRestAlert(id: id)
        }
    }

    static func restNotificationRequest(id: String, deadline: Date, now: Date) -> UNNotificationRequest? {
        let interval = deadline.timeIntervalSince(now)
        guard interval > 0 else { return nil }
        let content = UNMutableNotificationContent()
        content.title = String(localized: .uiRestFinished)
        content.body = String(localized: .uiTimeForNextSet)
        content.sound = UNNotificationSound(named: UNNotificationSoundName("rest-complete.wav"))
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }

    static func notificationRequest(for request: WorkoutReminderRequest) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = WorkoutReminderRequest.title
        content.body = WorkoutReminderRequest.body
        content.sound = .default
        // No fixed time zone or date: the trigger follows the device's local weekly clock.
        var date = DateComponents()
        date.weekday = request.weekday
        date.hour = request.time.hour
        date.minute = request.time.minute
        date.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        return UNNotificationRequest(identifier: request.identifier, content: content, trigger: trigger)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let id = notification.request.identifier
        if WorkoutReminderRequest.identifiers.contains(id) { return [.banner, .list, .sound] }
        return await shouldPresentRestAlert(id: id) ? [.banner, .list, .sound] : []
    }

    private func shouldPresentRestAlert(id: String) -> Bool {
        restAlerts?.shouldPresentNotification(id: id) == true
    }
}
