/// System boundary for permission and this feature's pending notifications only.
@MainActor
protocol WorkoutNotificationClient {
    func authorizationStatus() async -> ReminderAuthorization
    func requestAuthorization() async throws -> Bool
    func removePendingReminders() async
    func add(_ request: WorkoutReminderRequest) async throws
}
