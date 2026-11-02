import Foundation

@MainActor
extension Exercise {
    func snapshot() -> ExerciseSnapshot {
        ExerciseSnapshot(
            id: id,
            name: name,
            primaryMuscle: primaryMuscle,
            secondaryMuscles: secondaryMuscles,
            equipment: equipment,
            frequencyPreference: frequencyPreference
        )
    }
}
