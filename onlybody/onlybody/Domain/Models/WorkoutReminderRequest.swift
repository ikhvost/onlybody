/// A weekly reminder; weekday uses the existing Sunday = 1 through Saturday = 7 convention.
nonisolated struct WorkoutReminderRequest: Sendable, Equatable {
    static let identifierPrefix = "workout-reminder.weekday."
    static let identifiers = (1...7).map { "\(identifierPrefix)\($0)" }
    static let title = "Training day"
    static let body = "You have a workout scheduled for today."

    let weekday: Int
    let time: WorkoutReminderTime

    var identifier: String { "\(Self.identifierPrefix)\(weekday)" }
}
