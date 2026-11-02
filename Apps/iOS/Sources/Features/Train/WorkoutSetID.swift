import Foundation

/// Stable within a session even when exercise occurrences are reordered.
struct WorkoutSetID: Hashable, Sendable {
    let itemID: UUID
    let index: Int
}
