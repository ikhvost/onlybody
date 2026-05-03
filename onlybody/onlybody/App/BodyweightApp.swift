import SwiftData
import SwiftUI

@main
struct BodyweightApp: App {
    let container: ModelContainer
    let exercises: any ExerciseRepository
    let workouts: any WorkoutRepository
    let sessions: any SessionRepository

    init() {
        do {
            container = try ModelContainer(for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self)
            let context = container.mainContext
            exercises = SwiftDataExerciseRepository(context: context)
            workouts = SwiftDataWorkoutRepository(context: context)
            sessions = SwiftDataSessionRepository(context: context)
            SeedManager.seedIfNeeded(context: context)
        } catch {
            fatalError("ModelContainer failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppTabView(exercises: exercises, workouts: workouts, sessions: sessions)
        }
    }
}
