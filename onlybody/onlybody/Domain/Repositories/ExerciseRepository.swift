/// Persistence boundary exposing detached domain values.
@MainActor
protocol ExerciseRepository: Sendable {
    /// Returns catalog values sorted by name.
    func allExercises() async throws -> [ExerciseSnapshot]
    /// Inserts or updates one exercise by UUID in a single commit.
    func save(_ exercise: ExerciseSnapshot) async throws
}
