import Foundation
import SwiftData

@Model
final class Exercise {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var primaryMuscle: String = ""
    var secondaryMuscles: [String] = []
    var equipment: [String] = []
    var frequencyPreference: String = ExerciseFrequency.normal.rawValue
    var isCustom: Bool = false

    init() {}

    var equipmentLabel: String {
        equipment.isEmpty ? "None" : equipment.joined(separator: ", ")
    }
}
