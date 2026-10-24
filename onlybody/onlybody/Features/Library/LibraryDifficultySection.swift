/// A nonempty group after all Library search and filter selections are applied.
nonisolated struct LibraryDifficultySection: Identifiable {
    let difficulty: ExerciseDifficulty
    let exercises: [ExerciseSnapshot]
    var id: ExerciseDifficulty { difficulty }
}
