import Foundation
@testable import onlybody

@MainActor
final class ManualWorkoutTimeSource: WorkoutTimeSource {
    var now = Date(timeIntervalSince1970: 1_700_000_000)
    private var sleepers: [UUID: (Date, CheckedContinuation<Void, any Error>)] = [:]
    var sleeperCount: Int { sleepers.count }

    func sleep(for duration: Duration) async throws {
        let id = UUID()
        let components = duration.components
        let seconds = Double(components.seconds) + Double(components.attoseconds) / 1e18
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                if Task.isCancelled {
                    continuation.resume(throwing: CancellationError())
                } else {
                    sleepers[id] = (now.addingTimeInterval(seconds), continuation)
                }
            }
        } onCancel: {
            Task { @MainActor in
                self.sleepers.removeValue(forKey: id)?.1.resume(throwing: CancellationError())
            }
        }
    }

    func advance(seconds: TimeInterval) {
        now = now.addingTimeInterval(seconds)
        for (id, sleeper) in sleepers where sleeper.0 <= now {
            sleepers.removeValue(forKey: id)?.1.resume()
        }
    }

    /// Bounded scheduling synchronization, never a real-time delay.
    func waitForSleepers(_ count: Int) async {
        for _ in 0..<1_000 {
            if sleeperCount == count { return }
            await Task.yield()
        }
    }
}
