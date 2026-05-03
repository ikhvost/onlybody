import Foundation
import Observation

@MainActor
@Observable
final class LogViewModel {
    private let sessionsRepository: any SessionRepository

    var sessions: [Session] = []
    var isLoading = false
    var errorMessage: String? = nil

    var monthSections: [(label: String, sessions: [Session])] {
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
        } catch {
            errorMessage = "Could not load training history."
        }
    }

    func dayText(for session: Session) -> String {
        session.date.formatted(.dateTime.day())
    }

    func weekdayText(for session: Session) -> String {
        session.date.formatted(.dateTime.weekday(.wide))
    }

    func durationText(for session: Session) -> String {
        Duration.seconds(session.durationSeconds)
            .formatted(.time(pattern: .minuteSecond))
    }

    func caloriesText(for session: Session) -> String {
        if let cals = session.caloriesBurned {
            return "\(cals) kcal"
        }
        return "—"
    }

    private let calendar = Calendar.current

    private func monthKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let year = components.year, let month = components.month else {
            return "0000-00"
        }
        return "\(year)-\(String(format: "%02d", month))"
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
}
