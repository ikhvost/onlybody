import Foundation

enum TrainRoute: Hashable {
    case smart(workoutID: UUID?, targets: [String] = [], opensPreview: Bool = false)
    case creation
    case overview(workoutID: UUID)
    case guide(exerciseID: UUID)
    case settings
    case notifications
    case sessionBuilder(workoutID: UUID?, targetMuscleGroups: [String] = [])
}
