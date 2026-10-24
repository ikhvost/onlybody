import Foundation
import SwiftData

@Model
final class Workout {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var mode: String = WorkoutMode.smart.rawValue
    var targetMuscleGroups: [String] = []
    var scheduledDays: [String] = []
    @Relationship(deleteRule: .cascade) var items: [WorkoutItem]?

    init() {}
}
