import Foundation

/// The reviewed daily plan, persisted independently from the workout template.
nonisolated struct SmartDailyVariant: Codable, Equatable, Sendable, Identifiable {
    var workoutID: UUID
    var localDay: String
    var settingsRevision: UUID
    var items: [WorkoutItemSnapshot]
    var estimatedSeconds: Int
    var uncoveredNeeds: [String]
    var createdAt: Date
    // Compatibility only: manual lists no longer require duration acceptance.
    var acceptedShortPlan: Bool?

    var id: String { "\(workoutID.uuidString)|\(localDay)|\(settingsRevision.uuidString)" }
}
