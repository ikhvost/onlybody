struct EmptyExerciseRepository: ExerciseRepository {
    func allExercises() async throws -> [Exercise] {
        []
    }

    func exercises(primaryMuscle: String) async throws -> [Exercise] {
        []
    }

    func exercises(matching name: String) async throws -> [Exercise] {
        []
    }

    func save(_ exercise: Exercise) async throws {}

    func delete(_ exercise: Exercise) async throws {}
}
