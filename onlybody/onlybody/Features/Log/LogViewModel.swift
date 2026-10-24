import Foundation
import Observation

@MainActor
@Observable
final class LogViewModel {
    private let sessionsRepository: any SessionRepository

    var stats = StreakStats(current: 0, longest: 0, total: 0)
    var heatmap: [[Bool]] = Array(repeating: Array(repeating: false, count: 20), count: 7)

    var activeDaysInHeatmap: Int { heatmap.flatMap { $0 }.filter { $0 }.count }

    var sessions: [SessionSnapshot] = []
    var isLoading = false
    var errorMessage: String?

    var monthSections: [(label: String, sessions: [SessionSnapshot])] {
        let grouped = Dictionary(grouping: sessions) { session in
            monthKey(for: session.date)
        }
        let sortedKeys = grouped.keys.sorted(by: >)
        return sortedKeys.map { key in
            let label = monthLabel(for: key)
            let sortedSessions = grouped[key]?.sorted { $0.date > $1.date } ?? []
            return (label, sortedSessions)
        }
    }

    init(sessions: any SessionRepository) {
        self.sessionsRepository = sessions
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            sessions = try await sessionsRepository.allSessions()
                .sorted { $0.date > $1.date }
            stats = StreakCalculator().calculate(sessions: sessions)
            heatmap = buildHeatmap(sessions: sessions)
        } catch {
            errorMessage = "Could not load training history."
        }
    }

    func dayText(for session: SessionSnapshot) -> String {
        session.date.formatted(.dateTime.day())
    }

    func weekdayText(for session: SessionSnapshot) -> String {
        session.date.formatted(.dateTime.weekday(.wide))
    }

    func durationText(for session: SessionSnapshot) -> String {
        Duration.seconds(session.durationSeconds)
            .formatted(.time(pattern: .minuteSecond))
    }

    private let calendar = Calendar.current

    private func monthKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let year = components.year, let month = components.month else {
            return "0000-00"
        }
        return "\(year)-\(month.formatted(.number.precision(.integerLength(2)).grouping(.never).locale(Locale(identifier: "en_US_POSIX"))))"
    }

    private func monthLabel(for key: String) -> String {
        let parts = key.split(separator: "-")
        guard parts.count == 2,
              let year = Int(parts[0]),
              let month = Int(parts[1]) else { return key }

        let monthName = calendar.monthSymbols[month - 1].uppercased()
        let currentYear = calendar.component(.year, from: Date())

        if year == currentYear {
            return monthName
        }
        return "\(monthName) \(year)"
    }
    private func buildHeatmap(sessions: [SessionSnapshot]) -> [[Bool]] {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        let weekday = calendar.component(.weekday, from: todayStart)
        let daysSinceMonday = weekday >= 2 ? weekday - 2 : 6
        guard let currentMonday = calendar.date(byAdding: .day, value: -daysSinceMonday, to: todayStart) else {
            return Array(repeating: Array(repeating: false, count: 20), count: 7)
        }

        guard let startMonday = calendar.date(byAdding: .day, value: -(19 * 7), to: currentMonday) else {
            return Array(repeating: Array(repeating: false, count: 20), count: 7)
        }

        var cells = Array(repeating: Array(repeating: false, count: 20), count: 7)

        for session in sessions {
            let day = calendar.startOfDay(for: session.date)
            let daysFromStart = calendar.dateComponents([.day], from: startMonday, to: day).day ?? -1
            guard daysFromStart >= 0, daysFromStart < 20 * 7 else { continue }

            let column = daysFromStart / 7
            let sessionWeekday = calendar.component(.weekday, from: day)
            let row = (sessionWeekday + 5) % 7

            guard row >= 0, row < 7, column >= 0, column < 20 else { continue }
            cells[row][column] = true
        }

        return cells
    }
}
