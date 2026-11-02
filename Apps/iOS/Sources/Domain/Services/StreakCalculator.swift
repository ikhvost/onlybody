import Foundation

nonisolated struct StreakCalculator: Sendable {

    func calculate(sessions: [SessionSnapshot], today: Date = .now, calendar: Calendar = .current) -> StreakStats {
        let total = sessions.count
        let todayStart = calendar.startOfDay(for: today)

        guard !sessions.isEmpty else {
            return StreakStats(current: 0, longest: 0, total: 0)
        }

        var uniqueDays: Set<Date> = []
        for session in sessions {
            uniqueDays.insert(calendar.startOfDay(for: session.date))
        }

        let sortedDays = uniqueDays.sorted()

        var current = 0
        if let lastDay = sortedDays.last, calendar.isDate(lastDay, inSameDayAs: today) {
            current = 1
            var cursor = calendar.date(byAdding: .day, value: -1, to: todayStart) ?? todayStart
            for day in sortedDays.dropLast().reversed() {
                if calendar.isDate(day, inSameDayAs: cursor) {
                    current += 1
                    guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                        break
                    }
                    cursor = previous
                } else {
                    break
                }
            }
        }

        var longest = 0
        if !sortedDays.isEmpty {
            var run = 1
            var prev = sortedDays[0]
            for i in 1..<sortedDays.count {
                let day = sortedDays[i]
                let diff = calendar.dateComponents([.day], from: prev, to: day).day ?? 0
                if diff == 1 {
                    run += 1
                } else {
                    longest = max(longest, run)
                    run = 1
                }
                prev = day
            }
            longest = max(longest, run)
        }

        return StreakStats(current: current, longest: longest, total: total)
    }
}
