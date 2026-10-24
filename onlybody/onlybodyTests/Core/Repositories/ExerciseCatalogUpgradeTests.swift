import Foundation
import SwiftData
import Testing
@testable import onlybody

@MainActor
struct ExerciseCatalogUpgradeTests {
    @Test func expandedCatalogPreservesExistingWorkoutAndHistoryWithoutBulkImport() async throws {
        let seed = try #require(Bundle.main.url(forResource: "default", withExtension: "store"))
        let catalog = try BundledExerciseCatalog.load(from: seed)
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appending(path: "existing.store")
        let container = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(url: storeURL)
        )
        let context = ModelContext(container)
        let existing = Exercise()
        existing.name = "Squats"
        existing.primaryMuscle = "Quads"
        existing.equipment = ["None"]
        existing.frequencyPreference = "never"
        context.insert(existing)
        let workout = Workout()
        workout.name = "My routine"
        let item = WorkoutItem()
        item.exercise = existing
        item.workout = workout
        workout.items = [item]
        context.insert(workout)
        let session = Session()
        session.workoutName = "My completed workout"
        context.insert(session)
        try context.save()

        let repository = SwiftDataExerciseRepository(context: ModelContext(container), catalog: catalog)
        let all = try await repository.allExercises()
        #expect(all.count == 65)
        #expect(all.first { $0.name == "Squats" }?.id == existing.id)
        #expect(all.first { $0.name == "Squats" }?.difficulty == .beginner)
        #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == 1)
        #expect(workout.items?.first?.exercise?.id == existing.id)
        #expect(try context.fetchCount(FetchDescriptor<Session>()) == 1)

        let newExercise = try #require(all.first { $0.name == "Bird Dog" })
        let workouts = SwiftDataWorkoutRepository(context: ModelContext(container), catalog: catalog)
        var value = WorkoutSnapshot()
        value.name = "With a new movement"
        var newItem = WorkoutItemSnapshot()
        newItem.exercise = newExercise
        value.items = [newItem]
        try await workouts.save(value)
        let readContext = ModelContext(container)
        #expect(try readContext.fetchCount(FetchDescriptor<Exercise>()) == 2)
        #expect(try await workouts.workout(by: value.id)?.items.first?.exercise?.id == newExercise.id)
        try await workouts.save(value)
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<Exercise>()) == 2)
        #expect(try await workouts.workout(by: workout.id)?.items.first?.exercise?.id == existing.id)
        #expect(try ModelContext(container).fetch(FetchDescriptor<Session>()).first?.workoutName == "My completed workout")

        let reopened = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(url: storeURL)
        )
        let reopenedWorkouts = SwiftDataWorkoutRepository(context: ModelContext(reopened), catalog: catalog)
        #expect(try await reopenedWorkouts.workout(by: value.id)?.items.first?.exercise?.id == newExercise.id)
        #expect(try await reopenedWorkouts.workout(by: workout.id)?.items.first?.exercise?.id == existing.id)

        let generator = SmartWorkoutGenerator(randomSets: { _ in 3 }, randomReps: { _ in 10 }, randomRest: { _ in 30 })
        let legacySnapshot = existing.snapshot()
        let result = generator.generate(config: SmartWorkoutConfiguration(targetMuscleGroups: ["Quads"], durationMinutes: 10), from: [legacySnapshot])
        #expect(result.first?.exercise.id == existing.id)
    }

    @Test func failedWorkoutRollsBackOnDemandCatalogInsertion() async throws {
        let container = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        var valid = ExerciseSnapshot()
        valid.name = "Bird Dog"
        let repository = SwiftDataWorkoutRepository(context: ModelContext(container), catalog: [valid])
        var workout = WorkoutSnapshot()
        var validItem = WorkoutItemSnapshot()
        validItem.exercise = valid
        var missingItem = WorkoutItemSnapshot()
        missingItem.exercise = ExerciseSnapshot()
        workout.items = [validItem, missingItem]
        await #expect(throws: PersistenceError.self) { try await repository.save(workout) }
        let context = ModelContext(container)
        #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Workout>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<WorkoutItem>()) == 0)
    }
}
