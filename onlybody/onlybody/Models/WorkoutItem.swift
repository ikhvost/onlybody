import Foundation
import SwiftData

@Model
final class WorkoutItem {
    var id: UUID = UUID()
    var order: Int = 0
    var sets: Int = 3
    var targetReps: Int = 12
    var restSeconds: Int = 45
    var exercise: Exercise? = nil

    init() {}
}
