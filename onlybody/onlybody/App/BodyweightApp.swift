import SwiftData
import SwiftUI

@main
struct BodyweightApp: App {
    let container: ModelContainer
    let repositories: Repositories

    init() {
        do {
            container = try ModelContainer(for: Exercise.self, WorkoutItem.self)
            repositories = Repositories(exercises: SwiftDataExerciseRepository(context: container.mainContext))
            SeedManager.seedIfNeeded(context: container.mainContext)
        } catch {
            fatalError("ModelContainer failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppTabView(repositories: repositories)
                .modelContainer(container)
        }
    }
}
