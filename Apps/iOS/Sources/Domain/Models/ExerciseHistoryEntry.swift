import Foundation

/// Completed occurrences of one named exercise in a saved workout.
nonisolated struct ExerciseHistoryEntry: Identifiable, Sendable, Equatable {
    let id: UUID
    let date: Date
    let workoutName: String
    let items: [SessionItemSnapshot]

    var totalReps: Int { items.reduce(0) { $0 + $1.setReps.reduce(0, +) } }
    var totalSets: Int { items.reduce(0) { $0 + $1.setReps.count } }
}
