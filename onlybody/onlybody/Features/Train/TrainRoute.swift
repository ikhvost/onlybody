import Foundation

enum TrainRoute: Hashable {
    case settings
    case musclePicker
    case sessionBuilder(workoutID: UUID?, targetMuscleGroups: [String] = [])
}
