/// Derived workout information; never persisted.
nonisolated struct WorkoutMuscleSummary: Equatable, Sendable {
    let ranked: [WorkoutMuscleCount]
    let secondary: [String]
    let missingExercises: Int
    let totalSets: Int

    var focus: [String] { ranked.filter { $0.sets == ranked.first?.sets }.map(\.muscle) }
    var diagram: MuscleDiagram { MuscleDiagram(primaryMuscles: ranked.map(\.muscle), secondaryMuscles: secondary) }
}
