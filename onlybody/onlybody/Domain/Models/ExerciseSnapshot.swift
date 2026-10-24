import Foundation

/// A detached value that never exposes a persistence context.
nonisolated struct ExerciseSnapshot: Identifiable, Sendable, Equatable {
    var id: UUID = UUID()
    var name: String = ""
    var primaryMuscle: String = ""
    var secondaryMuscles: [String] = []
    var equipment: [String] = []
    var frequencyPreference: String = ExerciseFrequency.normal.rawValue

    var equipmentLabel: String {
        equipment.isEmpty ? "None" : equipment.joined(separator: ", ")
    }
}
