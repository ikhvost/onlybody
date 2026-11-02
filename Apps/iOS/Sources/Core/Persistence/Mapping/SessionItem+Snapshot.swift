import Foundation

@MainActor
extension SessionItem {
    func snapshot() -> SessionItemSnapshot {
        SessionItemSnapshot(
            id: id,
            order: order,
            exerciseName: exerciseName,
            plannedSets: plannedSets,
            plannedReps: plannedReps,
            setReps: setReps,
            weightKg: weightKg,
            setWeightsKg: setWeightsKg
        )
    }
}
