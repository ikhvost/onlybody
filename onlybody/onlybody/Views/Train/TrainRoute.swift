import Foundation

enum TrainRoute: Hashable {
    case musclePicker
    case sessionBuilder(workoutID: UUID?, targetMuscleGroups: [String] = [])
}
