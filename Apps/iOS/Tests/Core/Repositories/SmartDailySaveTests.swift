import Foundation
import SwiftData
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartDailySaveTests {
    @Test func aggregateFailureRollsBackDailyListAndWorkoutTogether() async throws {
        let container = try ModelContainer(for: Exercise.self, Workout.self, WorkoutItem.self,
            SmartWorkoutSettingsRecord.self, SmartDailyVariantRecord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let exercise = ExerciseSnapshot(name: "Stored", primaryMuscle: "Chest")
        try await SwiftDataExerciseRepository(context: ModelContext(container)).save(exercise)
        let workouts = SwiftDataWorkoutRepository(context: ModelContext(container))
        let settings = SmartWorkoutSettings(configuration: SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"]))
        let workout = WorkoutSnapshot(name: "Original", smartSettings: settings, items: [WorkoutItemSnapshot(exercise: exercise)])
        let daily = SmartDailyVariant(workoutID: workout.id, localDay: "2026-11-11", settingsRevision: settings.revision,
            items: workout.items, estimatedSeconds: 100, uncoveredNeeds: [], createdAt: Date())
        try await workouts.save(workout, dailyVariant: daily)
        var changed = workout
        changed.name = "Must roll back"
        changed.items[0].exercise = ExerciseSnapshot(name: "Missing catalog entry")
        var changedDaily = daily
        changedDaily.items = changed.items
        await #expect(throws: PersistenceError.self) { try await workouts.save(changed, dailyVariant: changedDaily) }
        let reopened = SwiftDataWorkoutRepository(context: ModelContext(container))
        let variants = SwiftDataSmartDailyVariantRepository(context: ModelContext(container))
        #expect(try await reopened.workout(by: workout.id) == workout)
        #expect(try await variants.variant(workoutID: workout.id, localDay: daily.localDay, settingsRevision: settings.revision) == daily)
    }

    @Test func savedManualDailyEditsReopenWithTheirOriginalSettings() async throws {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "daily.store")
        let exercise = ExerciseSnapshot(name: "Different muscle", primaryMuscle: "Quads")
        let settings = SmartWorkoutSettings(configuration: SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"],
            level: .advanced, excludedExercises: [exercise.name], excludedRegions: [.knee]))
        let workout = WorkoutSnapshot(name: "Daily", smartSettings: settings, items: [WorkoutItemSnapshot(exercise: exercise)])
        let daily = SmartDailyVariant(workoutID: workout.id, localDay: "2026-11-11", settingsRevision: settings.revision,
            items: workout.items, estimatedSeconds: 100, uncoveredNeeds: [], createdAt: Date())
        try await write(workout, daily: daily, exercise: exercise, url: url)
        let reopened = try container(url)
        #expect(try await SwiftDataWorkoutRepository(context: ModelContext(reopened)).workout(by: workout.id) == workout)
        #expect(try await SwiftDataSmartDailyVariantRepository(context: ModelContext(reopened))
            .variant(workoutID: workout.id, localDay: daily.localDay, settingsRevision: settings.revision) == daily)
    }

    private func write(_ workout: WorkoutSnapshot, daily: SmartDailyVariant, exercise: ExerciseSnapshot, url: URL) async throws {
        let store = try container(url)
        let repository = SwiftDataWorkoutRepository(context: ModelContext(store), catalog: [exercise])
        try await repository.save(workout, dailyVariant: daily)
    }

    private func container(_ url: URL) throws -> ModelContainer {
        try ModelContainer(for: Exercise.self, Workout.self, WorkoutItem.self, SmartWorkoutSettingsRecord.self,
            SmartDailyVariantRecord.self, configurations: ModelConfiguration(url: url))
    }
}
