#if DEBUG
struct PreviewExerciseRepository: ExerciseRepository {
    let exercises: [Exercise]

    init(exercises: [Exercise] = []) {
        self.exercises = exercises
    }

    func allExercises() async throws -> [Exercise] {
        exercises
    }

    func save(_ exercise: Exercise) async throws {}
}
#endif
