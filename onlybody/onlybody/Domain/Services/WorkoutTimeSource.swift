import Foundation

/// Time and suspension shared by elapsed and rest timers; tests advance it explicitly.
@MainActor
protocol WorkoutTimeSource {
    var now: Date { get }
    func sleep(for duration: Duration) async throws
}
