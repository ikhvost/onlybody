import Foundation

/// Gregorian civil dates respect the supplied local time zone, including DST changes.
nonisolated struct SmartPlanningClock: Sendable {
    var calendar: Calendar = .autoupdatingCurrent

    func localDay(at date: Date) -> String {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let parts = gregorian.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)"
    }

    func variationSeed(workoutID: UUID, localDay: String) -> UInt64 {
        stableScore(workoutID.uuidString + localDay)
    }

    func stableScore(_ text: String, seed: UInt64 = 0) -> UInt64 {
        text.utf8.reduce(14_695_981_039_346_656_037 ^ seed) { ($0 ^ UInt64($1)) &* 1_099_511_628_211 }
    }
}
