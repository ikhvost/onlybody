import Foundation
import SwiftData

@Model
final class SessionItem {
    var id: UUID = UUID()
    var order: Int = 0
    var exerciseName: String = ""
    var plannedSets: Int = 3
    var plannedReps: Int = 12
    var setReps: [Int] = []
    var weightKg: Double? = nil

    init() {}
}
