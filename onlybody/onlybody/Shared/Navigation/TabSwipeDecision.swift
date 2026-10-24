import Foundation

/// Pure threshold calculation shared by the recognizer and regression tests.
nonisolated enum TabSwipeDecision {
    static func accepts(
        horizontal: Double, vertical: Double, velocity: Double,
        thresholds: TabSwipeThresholds
    ) -> Bool {
        guard abs(horizontal) >= thresholds.minimum, abs(horizontal) > abs(vertical) * thresholds.ratio else { return false }
        return abs(horizontal) >= thresholds.distance
            || (abs(horizontal) >= thresholds.fastDistance && abs(velocity) >= thresholds.speed && horizontal * velocity > 0)
    }
}
