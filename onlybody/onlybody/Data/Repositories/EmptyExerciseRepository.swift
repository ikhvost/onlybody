struct EmptyExerciseRepository: ExerciseRepository {
    func allExercises() async throws -> [Exercise] {
        []
    }

    func save(_ exercise: Exercise) async throws {}
}
