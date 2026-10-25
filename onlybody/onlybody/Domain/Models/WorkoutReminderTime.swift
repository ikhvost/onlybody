/// A local clock time on the reminder's fifteen-minute grid.
nonisolated struct WorkoutReminderTime: Sendable, Hashable {
    static let defaultMinutes = 13 * 60
    static let options = stride(from: 0, to: 24 * 60, by: 15).map { WorkoutReminderTime(minutes: $0) }

    let minutes: Int

    init(minutes: Int = Self.defaultMinutes) {
        self.minutes = (0..<1440).contains(minutes) && minutes.isMultiple(of: 15) ? minutes : Self.defaultMinutes
    }

    var hour: Int { minutes / 60 }
    var minute: Int { minutes % 60 }

    var label: String {
        let hours = hour < 10 ? "0\(hour)" : "\(hour)"
        let minutes = minute < 10 ? "0\(minute)" : "\(minute)"
        return "\(hours):\(minutes)"
    }
}
