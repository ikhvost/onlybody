/// App-level notification permission, independent of the system notification framework.
nonisolated enum ReminderAuthorization: Sendable {
    case notDetermined
    case denied
    case authorized
}
