import Foundation

nonisolated struct SmartWorkoutConfiguration: Sendable {
    let targetMuscleGroups: [String]
    let durationMinutes: Int

    init(targetMuscleGroups: [String], durationMinutes: Int = 30) {
        self.targetMuscleGroups = targetMuscleGroups
        self.durationMinutes = durationMinutes
    }
}
