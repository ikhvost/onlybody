import Foundation
import Testing
@testable import onlybody

@MainActor
struct LogViewModelTests {
    @Test
    func loadPopulatesSessionsSortedNewestFirst() async {
        let sessionRepo = MockSessionRepository()

        let oldest = Session()
        oldest.id = UUID()
        oldest.workoutName = "Oldest"
        oldest.date = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 10))!

        let newest = Session()
        newest.id = UUID()
        newest.workoutName = "Newest"
        newest.date = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 1))!

        let middle = Session()
        middle.id = UUID()
        middle.workoutName = "Middle"
        middle.date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 15))!

        sessionRepo.stubbedSessions = [oldest, middle, newest]

        let viewModel = LogViewModel(sessions: sessionRepo)
        await viewModel.load()

        let names = viewModel.sessions.map(\.workoutName)
        #expect(names == ["Newest", "Middle", "Oldest"])
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test
    func loadSetsErrorMessageWhenRepositoryFails() async {
        let sessionRepo = MockSessionRepository()
        sessionRepo.shouldThrow = true

        let viewModel = LogViewModel(sessions: sessionRepo)
        await viewModel.load()

        #expect(viewModel.sessions.isEmpty)
        #expect(viewModel.errorMessage == "Could not load training history.")
        #expect(viewModel.isLoading == false)
    }

    @Test
    func monthSectionsGroupsByMonth() async {
        let sessionRepo = MockSessionRepository()

        let maySession = Session()
        maySession.id = UUID()
        maySession.workoutName = "May Workout"
        maySession.date = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 1))!

        let aprilSession = Session()
        aprilSession.id = UUID()
        aprilSession.workoutName = "April Workout"
        aprilSession.date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 25))!

        let alsoApril = Session()
        alsoApril.id = UUID()
        alsoApril.workoutName = "Also April"
        alsoApril.date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 20))!

        sessionRepo.stubbedSessions = [maySession, aprilSession, alsoApril]

        let viewModel = LogViewModel(sessions: sessionRepo)
        await viewModel.load()

        let sections = viewModel.monthSections
        #expect(sections.count == 2)

        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMay = Calendar.current.monthSymbols[4].uppercased()
        let currentApril = Calendar.current.monthSymbols[3].uppercased()

        if currentYear == 2026 {
            #expect(sections[0].label == currentMay)
            #expect(sections[1].label == currentApril)
        }

        #expect(sections[0].sessions.count == 1)
        #expect(sections[0].sessions.first?.workoutName == "May Workout")
        #expect(sections[1].sessions.count == 2)
        #expect(sections[1].sessions.map(\.workoutName) == ["April Workout", "Also April"])
    }

    @Test
    func emptySessionsReturnsEmptySections() async {
        let sessionRepo = MockSessionRepository()
        sessionRepo.stubbedSessions = []

        let viewModel = LogViewModel(sessions: sessionRepo)
        await viewModel.load()

        #expect(viewModel.sessions.isEmpty)
        #expect(viewModel.monthSections.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func caloriesTextHandlesNilGracefully() async {
        let sessionRepo = MockSessionRepository()

        let withCals = Session()
        withCals.id = UUID()
        withCals.workoutName = "With Cals"
        withCals.caloriesBurned = 150
        withCals.date = Date()

        let withoutCals = Session()
        withoutCals.id = UUID()
        withoutCals.workoutName = "No Cals"
        withoutCals.caloriesBurned = nil
        withoutCals.date = Date()

        sessionRepo.stubbedSessions = [withCals, withoutCals]

        let viewModel = LogViewModel(sessions: sessionRepo)
        await viewModel.load()

        #expect(viewModel.caloriesText(for: withCals) == "150 kcal")
        #expect(viewModel.caloriesText(for: withoutCals) == "—")
    }

    @Test
    func durationTextFormatsMinutesAndSeconds() async {
        let sessionRepo = MockSessionRepository()

        let session = Session()
        session.id = UUID()
        session.workoutName = "Test"
        session.durationSeconds = 1450
        session.date = Date()

        sessionRepo.stubbedSessions = [session]

        let viewModel = LogViewModel(sessions: sessionRepo)
        await viewModel.load()

        #expect(viewModel.durationText(for: session) == "24:10")
    }

    @Test
    func pastYearMonthLabelIncludesYear() async {
        let sessionRepo = MockSessionRepository()

        let pastSession = Session()
        pastSession.id = UUID()
        pastSession.workoutName = "Past"
        pastSession.date = Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 15))!

        sessionRepo.stubbedSessions = [pastSession]

        let viewModel = LogViewModel(sessions: sessionRepo)
        await viewModel.load()

        let sections = viewModel.monthSections
        #expect(sections.count == 1)
        #expect(sections[0].label == "DECEMBER 2024")
    }

    @Test
    func loadGuardsAgainstConcurrentCalls() async {
        let sessionRepo = MockSessionRepository()
        let session = Session()
        session.workoutName = "Test"
        session.date = Date()
        sessionRepo.stubbedSessions = [session]

        let viewModel = LogViewModel(sessions: sessionRepo)

        // Gun off two concurrent loads
        async let _ = viewModel.load()
        async let _ = viewModel.load()

        // Wait for both to potentially finish
        try? await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.sessions.count == 1)
    }
}
