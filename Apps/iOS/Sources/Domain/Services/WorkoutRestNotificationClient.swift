import Foundation

/// Local notifications belonging to the active rest timer.
@MainActor
protocol WorkoutRestNotificationClient {
    func restAlertAuthorization() async -> ReminderAuthorization
    func requestAuthorization() async throws -> Bool
    func scheduleRestAlert(id: String, deadline: Date) async throws -> Bool
    func removeRestAlert(id: String)
}
