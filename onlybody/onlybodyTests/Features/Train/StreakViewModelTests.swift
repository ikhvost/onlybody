import Foundation
import Testing
@testable import onlybody

@MainActor
struct StreakViewModelTests {
    private let calendar = Calendar.current

    private func makeSession(daysAgo: Int) -> Session {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        let session = Session()
        session.date = date
        return session
    }

    // MARK: - Load populates stats

    @Test
    func loadPopulatesStatsFromSessions() async {
        let repo = MockSessionRepository()
        repo.stubbedSessions = [
            makeSession(daysAgo: 2),
            makeSession(daysAgo: 1),
            makeSession(daysAgo: 0),
        ]

        let viewModel = StreakViewModel(sessions: repo)
        await viewModel.load()

        #expect(viewModel.stats.current == 3)
        #expect(viewModel.stats.longest == 3)
        #expect(viewModel.stats.total == 3)
    }

    @Test
    func emptySessionsProducesZeroStats() async {
        let repo = MockSessionRepository()
        repo.stubbedSessions = []

        let viewModel = StreakViewModel(sessions: repo)
        await viewModel.load()

        #expect(viewModel.stats.current == 0)
        #expect(viewModel.stats.longest == 0)
        #expect(viewModel.stats.total == 0)
    }

    // MARK: - Heatmap dimensions

    @Test
    func heatmapHasSevenRows() async {
        let repo = MockSessionRepository()
        repo.stubbedSessions = []

        let viewModel = StreakViewModel(sessions: repo)
        await viewModel.load()

        #expect(viewModel.heatmap.count == 7)
    }

    @Test
    func heatmapHasTwentyColumns() async {
        let repo = MockSessionRepository()
        repo.stubbedSessions = []

        let viewModel = StreakViewModel(sessions: repo)
        await viewModel.load()

        for row in viewModel.heatmap {
            #expect(row.count == 20)
        }
    }

    // MARK: - Heatmap cells reflect sessions

    @Test
    func sessionTodayMarksHeatmapCell() async {
        let repo = MockSessionRepository()
        repo.stubbedSessions = [makeSession(daysAgo: 0)]

        let viewModel = StreakViewModel(sessions: repo)
        await viewModel.load()

        let todayStart = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: todayStart)
        let todayRow = (weekday + 5) % 7

        #expect(viewModel.heatmap[todayRow][19])
    }

    @Test
    func emptySessionsProducesAllFalseHeatmap() async {
        let repo = MockSessionRepository()
        repo.stubbedSessions = []

        let viewModel = StreakViewModel(sessions: repo)
        await viewModel.load()

        for row in viewModel.heatmap {
            for cell in row {
                #expect(!cell)
            }
        }
    }

    // MARK: - isLoading

    @Test
    func loadSetsAndClearsIsLoading() async {
        let repo = MockSessionRepository()
        repo.stubbedSessions = []

        let viewModel = StreakViewModel(sessions: repo)
        await viewModel.load()

        #expect(!viewModel.isLoading)
    }

    // MARK: - Error handling

    @Test
    func repositoryErrorSetsErrorMessage() async {
        let repo = MockSessionRepository()
        repo.shouldThrow = true

        let viewModel = StreakViewModel(sessions: repo)
        await viewModel.load()

        #expect(viewModel.errorMessage != nil)
        #expect(!viewModel.isLoading)
    }

    @Test
    func successfulLoadClearsErrorMessage() async {
        let repo = MockSessionRepository()
        repo.stubbedSessions = []

        let viewModel = StreakViewModel(sessions: repo)
        await viewModel.load()

        #expect(viewModel.errorMessage == nil)
    }
}
