import Foundation

/// A detached value that never exposes a persistence context.
nonisolated struct SessionItemSnapshot: Identifiable, Sendable, Equatable {
    var id: UUID = UUID()
    var order: Int = 0
    var exerciseName: String = ""
    var plannedSets: Int = 3
    var plannedReps: Int = 12
    var setReps: [Int] = []
    var weightKg: Double?
    var setWeightsKg: [Double]?

    /// Older records contain only an exercise-wide weight, not the weight of each set.
    func weightForSet(at index: Int) -> Double? {
        guard let setWeightsKg, setWeightsKg.indices.contains(index) else { return nil }
        return setWeightsKg[index]
    }
}
