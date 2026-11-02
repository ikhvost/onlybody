import Foundation
import SwiftData

/// Reads release content without copying over a user's workouts or importing rows at launch.
@MainActor
enum BundledExerciseCatalog {
    static func load(from url: URL) throws -> [ExerciseSnapshot] {
        // SQLite needs writable sidecar files even when fetching from a WAL seed store.
        // The app bundle is read-only; use a disposable copy, never the user's store.
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let copyURL = directory.appending(path: "catalog.store")
        try FileManager.default.copyItem(at: url, to: copyURL)
        return try readSnapshots(from: copyURL)
    }

    private static func readSnapshots(from url: URL) throws -> [ExerciseSnapshot] {
        let container = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(url: url, cloudKitDatabase: .none)
        )
        let context = ModelContext(container)
        context.autosaveEnabled = false
        return try context.fetch(FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\Exercise.name)]))
            .map { $0.snapshot() }
    }
}
