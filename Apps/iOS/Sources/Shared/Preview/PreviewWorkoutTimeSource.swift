#if DEBUG
import Foundation

/// Frozen clock for design review; sleeping remains cancellable when the review closes.
@MainActor
struct PreviewWorkoutTimeSource: WorkoutTimeSource {
    let now: Date
    func sleep(for duration: Duration) async throws { try await Task.sleep(for: .seconds(3_600)) }
}
#endif
