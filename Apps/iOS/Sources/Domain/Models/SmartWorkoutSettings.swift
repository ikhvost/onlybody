import Foundation

/// Owned by the workout aggregate; all settings and anchor changes share one revision.
nonisolated struct SmartWorkoutSettings: Codable, Equatable, Sendable {
    var revision: UUID = UUID()
    var configuration: SmartWorkoutConfiguration
    var mainExerciseNames: [String] = []
}
