import SwiftData
import SwiftUI

@main
struct BodyweightApp: App {
    let container: ModelContainer?
    let exercises: any ExerciseRepository
    let workouts: any WorkoutRepository
    let sessions: any SessionRepository

    init() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            container = nil
            exercises = PreviewExerciseRepository()
            workouts = PreviewWorkoutRepository()
            sessions = PreviewSessionRepository()
            return
        }
        #endif

        do {
            let storeURL = try AppStoreLocation.url()
            guard let seedURL = Bundle.main.url(forResource: "default", withExtension: "store") else {
                throw PersistenceError.exerciseUnavailable
            }
            let catalog = try BundledExerciseCatalog.load(from: seedURL)

            if !FileManager.default.fileExists(atPath: storeURL.path()) {
                try FileManager.default.copyItem(at: seedURL, to: storeURL)
            }

            let config = ModelConfiguration(url: storeURL)
            let storeContainer = try ModelContainer(
                for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
                configurations: config
            )
            container = storeContainer
            exercises = SwiftDataExerciseRepository(context: ModelContext(storeContainer), catalog: catalog)
            workouts = SwiftDataWorkoutRepository(context: ModelContext(storeContainer), catalog: catalog)
            sessions = SwiftDataSessionRepository(context: ModelContext(storeContainer))
        } catch {
            fatalError("ModelContainer failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppTabView(composition: AppComposition(exercises: exercises, workouts: workouts, sessions: sessions))
        }
    }
}
