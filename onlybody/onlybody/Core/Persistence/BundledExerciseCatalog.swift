import Foundation
import SwiftData

/// Reads release content without copying over a user's workouts or importing rows at launch.
@MainActor
enum BundledExerciseCatalog {
    static func load(from url: URL) throws -> [ExerciseSnapshot] {
        let container = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(url: url, allowsSave: false, cloudKitDatabase: .none)
        )
        let context = ModelContext(container)
        context.autosaveEnabled = false
        return try context.fetch(FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\Exercise.name)]))
            .map { $0.snapshot() }
    }
}
