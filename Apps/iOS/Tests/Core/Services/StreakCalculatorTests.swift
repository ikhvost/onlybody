import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct StreakCalculatorTests {
    private let calculator = StreakCalculator()
    private let referenceToday = Date(timeIntervalSince1970: 1_780_315_200)
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private func makeSession(daysAgo: Int) -> SessionSnapshot {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: referenceToday)!
        var session = SessionSnapshot()
        session.date = date
        return session
    }

    private func makeSession(on date: Date) -> SessionSnapshot {
        var session = SessionSnapshot()
        session.date = date
        return session
    }

    // MARK: - Empty

    @Test
    func emptySessionsReturnsAllZero() {
        let stats = calculator.calculate(sessions: [], today: referenceToday, calendar: calendar)

        #expect(stats.current == 0)
        #expect(stats.longest == 0)
        #expect(stats.total == 0)
    }

    // MARK: - Single session today

    @Test
    func oneSessionTodayProducesCurrentOneLongestOneTotalOne() {
        let session = makeSession(daysAgo: 0)
        let stats = calculator.calculate(sessions: [session], today: referenceToday, calendar: calendar)

        #expect(stats.current == 1)
        #expect(stats.longest == 1)
        #expect(stats.total == 1)
    }

    // MARK: - Single session yesterday

    @Test
    func oneSessionYesterdayProducesCurrentZeroLongestOneTotalOne() {
        let session = makeSession(daysAgo: 1)
        let stats = calculator.calculate(sessions: [session], today: referenceToday, calendar: calendar)

        #expect(stats.current == 0)
        #expect(stats.longest == 1)
        #expect(stats.total == 1)
    }

    // MARK: - Consecutive sessions through today

    @Test
    func consecutiveSessionsThroughToday() {
        let sessions = [
            makeSession(daysAgo: 3),
            makeSession(daysAgo: 2),
            makeSession(daysAgo: 1),
            makeSession(daysAgo: 0),
        ]
        let stats = calculator.calculate(sessions: sessions, today: referenceToday, calendar: calendar)

        #expect(stats.current == 4)
        #expect(stats.longest == 4)
        #expect(stats.total == 4)
    }

    // MARK: - Gap breaks current streak

    @Test
    func gapBreaksCurrentStreak() {
        let sessions = [
            makeSession(daysAgo: 4),
            makeSession(daysAgo: 1),
            makeSession(daysAgo: 0),
        ]
        let stats = calculator.calculate(sessions: sessions, today: referenceToday, calendar: calendar)

        #expect(stats.current == 2)
        #expect(stats.longest == 2)
        #expect(stats.total == 3)
    }

    // MARK: - Past longest preserved

    @Test
    func pastLongestPreservedWhenCurrentShorter() {
        let today = calendar.startOfDay(for: referenceToday)

        let fourteenDaysAgo = calendar.date(byAdding: .day, value: -14, to: today)!
        let thirteenDaysAgo = calendar.date(byAdding: .day, value: -13, to: today)!
        let twelveDaysAgo = calendar.date(byAdding: .day, value: -12, to: today)!
        let elevenDaysAgo = calendar.date(byAdding: .day, value: -11, to: today)!
        let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: today)!
        let nineDaysAgo = calendar.date(byAdding: .day, value: -9, to: today)!
        let eightDaysAgo = calendar.date(byAdding: .day, value: -8, to: today)!

        let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: today)!

        let sessions = [
            makeSession(on: fourteenDaysAgo),
            makeSession(on: thirteenDaysAgo),
            makeSession(on: twelveDaysAgo),
            makeSession(on: elevenDaysAgo),
            makeSession(on: tenDaysAgo),
            makeSession(on: nineDaysAgo),
            makeSession(on: eightDaysAgo),
            makeSession(on: oneDayAgo),
            makeSession(daysAgo: 0),
        ]

        let stats = calculator.calculate(sessions: sessions, today: referenceToday, calendar: calendar)

        #expect(stats.current == 2)
        #expect(stats.longest == 7)
        #expect(stats.total == 9)
    }

    // MARK: - Duplicate sessions same day

    @Test
    func duplicateSessionsSameDayDoNotInflateStreaks() {
        let sessions = [
            makeSession(daysAgo: 2),
            makeSession(daysAgo: 2),
            makeSession(daysAgo: 1),
            makeSession(daysAgo: 1),
            makeSession(daysAgo: 0),
        ]
        let stats = calculator.calculate(sessions: sessions, today: referenceToday, calendar: calendar)

        #expect(stats.current == 3)
        #expect(stats.longest == 3)
        #expect(stats.total == 5)
    }

    // MARK: - Total is raw count

    @Test
    func totalUsesRawSessionCountNotDeduplicatedDays() {
        let sessions = [
            makeSession(daysAgo: 2),
            makeSession(daysAgo: 2),
            makeSession(daysAgo: 2),
            makeSession(daysAgo: 0),
        ]
        let stats = calculator.calculate(sessions: sessions, today: referenceToday, calendar: calendar)

        #expect(stats.current == 1)
        #expect(stats.total == 4)
    }

    // MARK: - Today parameter

    @Test
    func respectsTodayParameter() {
        let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 5, day: 5))!

        let sessionDate = calendar.date(from: DateComponents(year: 2026, month: 5, day: 5))!
        let session = makeSession(on: sessionDate)

        let stats = calculator.calculate(sessions: [session], today: referenceDate, calendar: calendar)

        #expect(stats.current == 1)
        #expect(stats.longest == 1)
        #expect(stats.total == 1)
    }

    @Test
    func yesterdayDoesNotCountWithTodayParameter() {
        let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 5, day: 5))!

        let sessionDate = calendar.date(from: DateComponents(year: 2026, month: 5, day: 4))!
        let session = makeSession(on: sessionDate)

        let stats = calculator.calculate(sessions: [session], today: referenceDate, calendar: calendar)

        #expect(stats.current == 0)
        #expect(stats.longest == 1)
        #expect(stats.total == 1)
    }
}
