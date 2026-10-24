import Foundation

nonisolated struct SmartWorkoutConfiguration: Sendable {
    let targetMuscleGroups: [String]
    let durationMinutes: Int
    let restSeconds: Int?

    init(targetMuscleGroups: [String], durationMinutes: Int = 30, restSeconds: Int? = nil) {
        self.targetMuscleGroups = targetMuscleGroups
        self.durationMinutes = durationMinutes
        self.restSeconds = restSeconds
    }
}
