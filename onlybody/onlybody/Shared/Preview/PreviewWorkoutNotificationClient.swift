#if DEBUG
/// No system requests or permission dialogs in previews and explicitly opted-in isolated UI tests.
@MainActor
struct PreviewWorkoutNotificationClient: WorkoutNotificationClient {
    func authorizationStatus() async -> ReminderAuthorization { .authorized }
    func requestAuthorization() async throws -> Bool { true }
    func removePendingReminders() async {}
    func add(_ request: WorkoutReminderRequest) async throws {}
}
#endif
