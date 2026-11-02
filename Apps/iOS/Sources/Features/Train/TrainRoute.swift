import Foundation

enum TrainRoute: Hashable {
    case creation
    case overview(workoutID: UUID)
    case guide(exerciseID: UUID)
    case settings
    case notifications
    case musclePicker
    case sessionBuilder(workoutID: UUID?, targetMuscleGroups: [String] = [])
}
