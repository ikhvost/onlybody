#if DEBUG
import Foundation

struct PreviewWorkoutRepository: WorkoutRepository {
    let workouts: [WorkoutSnapshot]

    init(workouts: [WorkoutSnapshot] = []) {
        self.workouts = workouts
    }

    func allWorkouts() async throws -> [WorkoutSnapshot] {
        workouts
    }

    func workout(by id: UUID) async throws -> WorkoutSnapshot? {
        workouts.first { $0.id == id }
    }

    func delete(by id: UUID) async throws {}

    func save(_ workout: WorkoutSnapshot) async throws {}

}
#endif
