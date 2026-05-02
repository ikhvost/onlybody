import Foundation
import SwiftData

@Model
final class WorkoutItem {
    var id: UUID = UUID()
    var order: Int = 0
    var sets: Int = 3
    var targetReps: Int = 12
    var restSeconds: Int = 45
    @Relationship var exercise: Exercise? = nil
    @Relationship(deleteRule: .nullify, inverse: \Workout.items) var workout: Workout? = nil

    init() {}
}
