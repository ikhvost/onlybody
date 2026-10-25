import Foundation

enum TrainRoute: Hashable {
    case settings
    case notifications
    case musclePicker
    case sessionBuilder(workoutID: UUID?, targetMuscleGroups: [String] = [])
}
