import Foundation

/// A detached value that never exposes a persistence context.
nonisolated struct WorkoutSnapshot: Identifiable, Sendable, Equatable {
    var id: UUID = UUID()
    var name: String = ""
    var mode: String = WorkoutMode.smart.rawValue
    var targetMuscleGroups: [String] = []
    var scheduledDays: [String] = []
    var durationMinutes: Int?
    var restSeconds: Int?
    var smartSettings: SmartWorkoutSettings?
    var items: [WorkoutItemSnapshot] = []

}
