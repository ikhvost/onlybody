import Foundation
import Observation

@MainActor
@Observable
final class StreakViewModel {
    private let sessionsRepository: any SessionRepository

    var stats = StreakCalculator.Stats(current: 0, longest: 0, total: 0)
    var heatmap: [[Bool]] = Array(repeating: Array(repeating: false, count: 20), count: 7)
    var isLoading = false
    var errorMessage: String?

    init(sessions: any SessionRepository) {
        self.sessionsRepository = sessions
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let sessions = try await sessionsRepository.allSessions()
            let calculator = StreakCalculator()
            stats = calculator.calculate(sessions: sessions)
            heatmap = buildHeatmap(sessions: sessions)
        } catch {
            errorMessage = "Could not load streak data."
        }
    }

    private func buildHeatmap(sessions: [Session]) -> [[Bool]] {
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
