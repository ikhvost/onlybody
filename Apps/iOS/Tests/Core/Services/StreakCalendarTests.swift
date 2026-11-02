import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct StreakCalendarTests {
    @Test func consecutiveLocalDaysAcrossDSTAndDuplicateSessions() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "Europe/Warsaw"))
        let dates = try [28, 29, 30].map { day in
            try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: 12)))
        }
        let sessions = (dates + [dates[2]]).map { SessionSnapshot(date: $0) }
        let result = StreakCalculator().calculate(sessions: sessions, today: dates[2], calendar: calendar)
        #expect(result.current == 3)
        #expect(result.longest == 3)
        #expect(result.total == 4)
        let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: dates[2]))
        #expect(StreakCalculator().calculate(sessions: sessions, today: tomorrow, calendar: calendar).current == 0)
    }
}
