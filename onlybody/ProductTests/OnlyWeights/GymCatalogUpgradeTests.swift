import Foundation
import SwiftData
import Testing
@testable import onlyweights

@MainActor
struct GymCatalogUpgradeTests {
    private let originalNames = [
        "Barbell Bench Press", "Incline Dumbbell Press", "Lat Pulldown", "Seated Cable Row",
        "Dumbbell Shoulder Press", "Dumbbell Lateral Raise", "Cable Face Pull", "Dumbbell Curl",
        "Cable Triceps Pushdown", "Barbell Back Squat", "Leg Press", "Barbell Romanian Deadlift",
        "Leg Extension", "Seated Leg Curl", "Standing Calf Raise", "Cable Crunch"
    ]

    @Test func expandingLibraryPreservesStoredIDsWorkoutsAndHistoryAcrossReopen() async throws {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "default.store")
        let seed = try #require(Bundle.main.url(forResource: "default", withExtension: "store"))
        let catalog = try BundledExerciseCatalog.load(from: seed)
        let original = try originalNames.map { name in
            var exercise = try #require(catalog.first { $0.name == name })
            exercise.id = UUID()
            if name == "Barbell Bench Press" { exercise.equipment = ["Barbell", "Flat Bench"] }
            return exercise
        }
        let bench = try #require(original.first)
        let oldWorkout = WorkoutSnapshot(name: "Existing gym routine", items: [WorkoutItemSnapshot(exercise: bench)])
        let history = SessionSnapshot(
            date: Date(timeIntervalSince1970: 1_700_000_000), durationSeconds: 900, workoutName: oldWorkout.name,
            items: [SessionItemSnapshot(exerciseName: bench.name, setReps: [12, 10, 8], weightKg: 40, setWeightsKg: [30, 35, 40])]
        )
        try await createOriginalStore(at: url, exercises: original, workout: oldWorkout, history: history)

        let container = try openStore(at: url)
        let exercises = SwiftDataExerciseRepository(context: ModelContext(container), catalog: catalog)
        let merged = try await exercises.allExercises()
        #expect(merged.count == 60)
        for entry in original {
            #expect(merged.first { $0.name == entry.name }?.id == entry.id)
        }
        #expect(merged.first { $0.name == bench.name }?.equipment.contains("Squat Rack") == true)
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<Exercise>()) == 16)
        let workouts = SwiftDataWorkoutRepository(context: ModelContext(container), catalog: catalog)
        let preserved = try #require(try await workouts.workout(by: oldWorkout.id))
        #expect(preserved.items.first?.id == oldWorkout.items.first?.id)
        #expect(preserved.items.first?.exercise?.id == bench.id)
        let added = try #require(merged.first { $0.name == "Weighted Dips" })
        let newWorkout = WorkoutSnapshot(name: "Weighted dips routine", items: [WorkoutItemSnapshot(exercise: added)])
        try await workouts.save(newWorkout)
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<Exercise>()) == 17)

        let reopened = try openStore(at: url)
        let reopenedWorkouts = SwiftDataWorkoutRepository(context: ModelContext(reopened), catalog: catalog)
        #expect(try await reopenedWorkouts.workout(by: oldWorkout.id)?.items.first?.exercise?.id == bench.id)
        #expect(try await reopenedWorkouts.workout(by: newWorkout.id)?.items.first?.exercise?.id == added.id)
        let sessions = SwiftDataSessionRepository(context: ModelContext(reopened))
        #expect(try await sessions.allSessions() == [history])
        let reopenedExercises = SwiftDataExerciseRepository(context: ModelContext(reopened), catalog: catalog)
        let reopenedLibrary = try await reopenedExercises.allExercises()
        #expect(reopenedLibrary.count == 60)
        #expect(reopenedLibrary.first { $0.name == added.name }?.id == added.id)
        for entry in original {
            #expect(reopenedLibrary.first { $0.name == entry.name }?.id == entry.id)
        }
    }

    private func createOriginalStore(
        at url: URL, exercises: [ExerciseSnapshot], workout: WorkoutSnapshot, history: SessionSnapshot
    ) async throws {
        let container = try openStore(at: url)
        let repository = SwiftDataExerciseRepository(context: ModelContext(container))
        for exercise in exercises { try await repository.save(exercise) }
        try await SwiftDataWorkoutRepository(context: ModelContext(container)).save(workout)
        try await SwiftDataSessionRepository(context: ModelContext(container)).save(history)
    }

    private func openStore(at url: URL) throws -> ModelContainer {
        try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(url: url)
        )
    }
}
