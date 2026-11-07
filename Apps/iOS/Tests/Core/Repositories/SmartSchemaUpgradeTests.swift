import Foundation
import SwiftData
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

/// Uses each product's original bundled schema, with real saved user aggregates before migration.
@MainActor
struct SmartSchemaUpgradeTests {
    @Test func additiveSchemaPreservesCatalogWorkoutsAndHistoryAcrossReopen() async throws {
        let seed = try #require(Bundle.main.url(forResource: "default", withExtension: "store"))
        let bytes = try Data(contentsOf: seed)
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "upgrade.store")
        try FileManager.default.copyItem(at: seed, to: url)
        let workoutID = UUID()
        let sessionID = UUID()
        let originals = try populateLegacy(url, workoutID: workoutID, sessionID: sessionID)
        try await verifyUpgrade(url, workoutID: workoutID, sessionID: sessionID, originals: originals)
        // A second independent open must retain both old data and new Smart records.
        let reopened = try container(url)
        let context = ModelContext(reopened)
        let workout = try #require(try await SwiftDataWorkoutRepository(context: context).workout(by: workoutID))
        #expect(workout.smartSettings?.configuration.level == .intermediate)
        #expect(workout.items.count == 1)
        #expect(try context.fetchCount(FetchDescriptor<SmartDailyVariantRecord>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<SessionItem>()) == 1)
        #expect(try Data(contentsOf: seed) == bytes)
    }

    private func populateLegacy(_ url: URL, workoutID: UUID, sessionID: UUID) throws -> [ExerciseSnapshot] {
        try autoreleasepool {
            let legacy = try ModelContainer(for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
                                            configurations: ModelConfiguration(url: url))
            let context = ModelContext(legacy)
            context.autosaveEnabled = false
            let exercises = try context.fetch(FetchDescriptor<Exercise>())
            let exercise = try #require(exercises.first)
            let workout = Workout()
            workout.id = workoutID
            workout.name = "Preserve my workout"
            workout.mode = WorkoutMode.manual.rawValue
            workout.scheduledDays = ["Mon", "Fri"]
            let item = WorkoutItem()
            item.exercise = exercise
            item.sets = 5
            item.targetReps = 13
            item.workout = workout
            workout.items = [item]
            context.insert(workout)
            let session = Session()
            session.id = sessionID
            session.workoutName = workout.name
            session.durationSeconds = 721
            let history = SessionItem()
            history.exerciseName = exercise.name
            history.setReps = [13, 12]
            history.setWeightsKg = [12.5, 15]
            session.items = [history]
            context.insert(session)
            try context.save()
            return exercises.map { $0.snapshot() }
        }
    }

    private func verifyUpgrade(_ url: URL, workoutID: UUID, sessionID: UUID, originals: [ExerciseSnapshot]) async throws {
        let upgraded = try container(url)
        let context = ModelContext(upgraded)
        let repository = SwiftDataWorkoutRepository(context: context)
        let workouts = try await repository.allWorkouts()
        var workout = try #require(workouts.first)
        #expect(workout.id == workoutID)
        #expect(workout.name == "Preserve my workout")
        #expect(workout.scheduledDays == ["Mon", "Fri"])
        #expect(workout.items.first?.sets == 5)
        #expect(workout.items.first?.targetReps == 13)
        #expect(workout.smartSettings == nil)
        let migrated = try await SwiftDataExerciseRepository(context: ModelContext(upgraded)).allExercises()
        #expect(migrated.sorted { $0.name < $1.name } == originals.sorted { $0.name < $1.name })
        let sessions = try await SwiftDataSessionRepository(context: ModelContext(upgraded)).allSessions()
        #expect(sessions.first?.id == sessionID)
        #expect(sessions.first?.durationSeconds == 721)
        #expect(sessions.first?.items.first?.setReps == [13, 12])
        #expect(sessions.first?.items.first?.setWeightsKg == [12.5, 15])
        let settings = SmartWorkoutSettings(configuration: SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], level: .intermediate))
        workout.smartSettings = settings
        try await repository.save(workout)
        let variant = SmartDailyVariant(workoutID: workoutID, localDay: "2026-11-6", settingsRevision: settings.revision,
            items: workout.items, estimatedSeconds: 600, uncoveredNeeds: [], createdAt: Date())
        let daily = SwiftDataSmartDailyVariantRepository(context: ModelContext(upgraded))
        try await daily.save(variant)
        #expect(try await daily.variant(workoutID: workoutID, localDay: variant.localDay, settingsRevision: settings.revision) == variant)
        // A failing aggregate write must roll back its settings as well as its items.
        var invalid = workout
        invalid.smartSettings?.configuration.level = .advanced
        invalid.items = [WorkoutItemSnapshot(exercise: ExerciseSnapshot(name: "unavailable"))]
        await #expect(throws: PersistenceError.self) { try await repository.save(invalid) }
        #expect(try await repository.workout(by: workoutID) == workout)
    }

    private func container(_ url: URL) throws -> ModelContainer {
        try ModelContainer(for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            SmartWorkoutSettingsRecord.self, SmartDailyVariantRecord.self, configurations: ModelConfiguration(url: url))
    }
}
