#if DEBUG
struct PreviewExerciseRepository: ExerciseRepository {
    let exercises: [ExerciseSnapshot]

    init(exercises: [ExerciseSnapshot] = []) {
        self.exercises = exercises
    }

    func allExercises() async throws -> [ExerciseSnapshot] {
        exercises
    }

    func save(_ exercise: ExerciseSnapshot) async throws {}
}
#endif
