#if DEBUG
import Foundation

struct PreviewWorkoutRepository: WorkoutRepository {
    let workouts: [Workout]

    init(workouts: [Workout] = []) {
        self.workouts = workouts
    }

    func allWorkouts() async throws -> [Workout] {
        workouts
    }

    func workout(by id: UUID) async throws -> Workout? {
        workouts.first { $0.id == id }
    }

    func save(_ workout: Workout) async throws {}

    func deleteItems(_ items: [WorkoutItem]) async throws {}
}
#endif
