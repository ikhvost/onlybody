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
    var acceptedShortPlan: Bool?

    var id: String { "\(workoutID.uuidString)|\(localDay)|\(settingsRevision.uuidString)" }
}
