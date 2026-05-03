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
            let storeURL = URL.documentsDirectory.appending(path: "default.store")

            if !FileManager.default.fileExists(atPath: storeURL.path()) {
                if let seedURL = Bundle.main.url(forResource: "default", withExtension: "store") {
                    try FileManager.default.copyItem(at: seedURL, to: storeURL)
                }
            }

            let config = ModelConfiguration(url: storeURL)
            container = try ModelContainer(
                for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
                configurations: config
            )
            let context = container.mainContext
            exercises = SwiftDataExerciseRepository(context: context)
            workouts = SwiftDataWorkoutRepository(context: context)
            sessions = SwiftDataSessionRepository(context: context)
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
