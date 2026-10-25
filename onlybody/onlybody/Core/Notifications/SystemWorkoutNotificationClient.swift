import UserNotifications

/// Owns only the seven weekly workout reminders; never removes another feature's requests.
@MainActor
final class SystemWorkoutNotificationClient: NSObject, WorkoutNotificationClient, UNUserNotificationCenterDelegate {
    private let center: UNUserNotificationCenter

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
        guard WorkoutReminderRequest.identifiers.contains(notification.request.identifier) else { return [] }
        return [.banner, .list, .sound]
    }
}
