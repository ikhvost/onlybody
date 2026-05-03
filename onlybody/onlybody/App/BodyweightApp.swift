import SwiftData
import SwiftUI

@main
struct BodyweightApp: App {
    let container: ModelContainer
    let exercises: any ExerciseRepository
    let workouts: any WorkoutRepository
    let sessions: any SessionRepository
    @State private var isLaunching = true

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
            ZStack {
                AppTabView(exercises: exercises, workouts: workouts, sessions: sessions)
                    .opacity(isLaunching ? 0 : 1)

                if isLaunching {
                    LaunchView()
                        .transition(.opacity)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(1.8))
                withAnimation(.easeInOut(duration: 0.4)) {
                    isLaunching = false
                }
            }
        }
    }
}
