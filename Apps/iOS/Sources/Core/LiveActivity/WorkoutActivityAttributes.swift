import ActivityKit
import Foundation

nonisolated struct WorkoutActivityAttributes: ActivityAttributes {
    typealias ContentState = WorkoutActivityState

    let sessionID: UUID
    let workoutName: String
}
