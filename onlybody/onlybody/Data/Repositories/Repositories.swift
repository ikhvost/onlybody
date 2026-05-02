import SwiftUI

struct Repositories: EnvironmentKey {
    static let defaultValue = Repositories(
        exercises: EmptyExerciseRepository(),
        workouts: FatalErrorWorkoutRepository(),
        sessions: FatalErrorSessionRepository()
    )

    let exercises: any ExerciseRepository
    let workouts: any WorkoutRepository
    let sessions: any SessionRepository
}

extension EnvironmentValues {
    var repositories: Repositories {
        get { self[Repositories.self] }
        set { self[Repositories.self] = newValue }
    }
}

private struct FatalErrorWorkoutRepository: WorkoutRepository {
    func allWorkouts() async throws -> [Workout] { fatalError("Not configured") }
    func save(_ workout: Workout) async throws { fatalError("Not configured") }
    func delete(_ workout: Workout) async throws { fatalError("Not configured") }
    func deleteItems(_ items: [WorkoutItem]) async throws { fatalError("Not configured") }
}

private struct FatalErrorSessionRepository: SessionRepository {
    func allSessions() async throws -> [Session] { fatalError("Not configured") }
    func recentSessions(limit: Int) async throws -> [Session] { fatalError("Not configured") }
    func save(_ session: Session) async throws { fatalError("Not configured") }
}
