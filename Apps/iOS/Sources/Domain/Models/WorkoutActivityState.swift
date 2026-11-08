import Foundation

/// The compact snapshot sent to the app's widget extension.
nonisolated struct WorkoutActivityState: Codable, Hashable, Sendable {
    var exerciseName: String?
    var setNumber: Int?
    var totalSets: Int?
    var allSetsCompleted = false
    var restStartedAt: Date?
    var restDeadline: Date?
}
