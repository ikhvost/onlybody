import Foundation
import SwiftData

@Model
final class Workout {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var mode: String = "smart"
    var targetMuscleGroups: [String] = []
    var scheduledDays: [String] = []
    var createdAt: Date = Date.now
    @Relationship(deleteRule: .nullify) var items: [WorkoutItem]? = nil

    init() {}
}
