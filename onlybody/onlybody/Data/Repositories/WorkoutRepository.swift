protocol WorkoutRepository: Sendable {
    func allWorkouts() async throws -> [Workout]
    func save(_ workout: Workout) async throws
    func delete(_ workout: Workout) async throws
    func deleteItems(_ items: [WorkoutItem]) async throws
}
