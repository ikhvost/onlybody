import Foundation
import SwiftData
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartConfigurationCompatibilityTests {
    // Captures the pre-regions wire format; deliberately not produced by the current encoder.
    private let legacyPayload = Data("""
        {"revision":"4ED16023-8F62-46BC-A518-16071AE1C645","configuration":{
        "targetMuscleGroups":["Chest"],"durationMinutes":45,"restSeconds":90,"level":"intermediate",
        "equipmentMode":"confirmed","availableEquipment":["Wall"],
        "excludedLoads":["jumping","palmSupport"],"excludedExercises":["Knee Push-Ups"]},
        "mainExerciseNames":["Wall Push-Ups"]}
        """.utf8)

    @Test func oldPayloadPreservesEveryExistingConstraint() throws {
        let old = try JSONDecoder().decode(SmartWorkoutSettings.self, from: legacyPayload)
        #expect(old.configuration.excludedRegions.isEmpty)
        #expect(old.configuration.excludedLoads == [.jumping, .palmSupport])
        #expect(old.configuration.excludedExercises == ["Knee Push-Ups"])
        #expect(old.configuration.availableEquipment == ["Wall"])
        #expect(old.configuration.restSeconds == 90)
        #expect(old.configuration.durationMinutes == 45)
        #expect(old.mainExerciseNames == ["Wall Push-Ups"])
        #expect(try JSONDecoder().decode(SmartWorkoutSettings.self, from: JSONEncoder().encode(old)) == old)
    }

    @Test(arguments: ["beginner", "intermediate", "advanced", "unrated"])
    func legacyLevelRoundTripsWithoutAffectingSelection(level: String) throws {
        let configuration = SmartWorkoutConfiguration(targetMuscleGroups: ["Full Body"], equipmentMode: .standardGym)
        let data = try JSONEncoder().encode(configuration)
        var payload = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        // Keep the old wire format as an independently supplied input, not a runtime setting.
        #expect(payload["level"] as? String == "beginner")
        payload["level"] = level
        let legacy = try JSONDecoder().decode(SmartWorkoutConfiguration.self, from: JSONSerialization.data(withJSONObject: payload))
        let encoded = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(legacy)) as? [String: Any])
        #expect(encoded["level"] as? String == level)
        #expect(encoded["legacyLevel"] == nil)

        let seed = try #require(Bundle.main.url(forResource: "default", withExtension: "store"))
        let exercises = try BundledExerciseCatalog.load(from: seed)
        let generator = SmartSelectionGenerator()
        let expected = generator.plan(configuration: configuration, from: exercises)
        let actual = generator.plan(configuration: legacy, from: exercises)
        #expect(!expected.movements.isEmpty)
        #expect(actual.movements.map(\.exercise) == expected.movements.map(\.exercise))
        #expect(actual.movements.map(\.sets) == expected.movements.map(\.sets))
        #expect(actual.movements.map(\.reps) == expected.movements.map(\.reps))
        #expect(actual.movements.map(\.restSeconds) == expected.movements.map(\.restSeconds))
        #expect(actual.status == expected.status)
        #expect(actual.estimatedSeconds == expected.estimatedSeconds)
        #expect(actual.uncoveredNeeds == expected.uncoveredNeeds)
    }

    @Test func oldStoredSettingsAcceptMultipleRegionsAndSurviveIndependentReopen() async throws {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "compatibility.store")
        let id = UUID()
        try writeLegacyStore(url, id: id)
        let expected = try await updateRegions(url, id: id)
        let reopened = try container(url)
        let repository = SwiftDataWorkoutRepository(context: ModelContext(reopened))
        let actual = try #require(try await repository.workout(by: id))
        #expect(actual == expected)
        #expect(actual.smartSettings?.configuration.excludedRegions == [.knee, .hip])
        #expect(actual.smartSettings?.configuration.excludedLoads == [.jumping, .palmSupport])
        let settings = try #require(actual.smartSettings)
        let encoded = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(settings)) as? [String: Any])
        let configuration = try #require(encoded["configuration"] as? [String: Any])
        #expect(configuration["level"] as? String == "intermediate")
    }

    @Test func malformedRegionsFailWithoutResettingStoredSettings() async throws {
        let store = try ModelContainer(for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            SmartWorkoutSettingsRecord.self, SmartDailyVariantRecord.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(store)
        let workout = Workout()
        let record = SmartWorkoutSettingsRecord()
        record.workoutID = workout.id
        let oldJSON = try #require(String(bytes: legacyPayload, encoding: .utf8))
        record.payload = Data(oldJSON
            .replacing("\"durationMinutes\":45", with: "\"excludedRegions\":[\"unknown-region\"],\"durationMinutes\":45").utf8)
        context.insert(workout)
        context.insert(record)
        try context.save()
        let bytes = record.payload
        await #expect(throws: DecodingError.self) { try await SwiftDataWorkoutRepository(context: context).workout(by: workout.id) }
        #expect(try context.fetchCount(FetchDescriptor<Workout>()) == 1)
        #expect(record.payload == bytes)
    }

    private func writeLegacyStore(_ url: URL, id: UUID) throws {
        let store = try container(url)
        let context = ModelContext(store)
        let workout = Workout()
        workout.id = id
        workout.name = "Preserve legacy restrictions"
        workout.scheduledDays = ["Mon", "Fri"]
        let record = SmartWorkoutSettingsRecord()
        record.workoutID = id
        record.payload = legacyPayload
        context.insert(workout)
        context.insert(record)
        try context.save()
    }

    private func updateRegions(_ url: URL, id: UUID) async throws -> WorkoutSnapshot {
        let store = try container(url)
        let repository = SwiftDataWorkoutRepository(context: ModelContext(store))
        var workout = try #require(try await repository.workout(by: id))
        #expect(workout.smartSettings?.configuration.excludedRegions.isEmpty == true)
        workout.smartSettings?.configuration.excludedRegions = [.knee, .hip]
        try await repository.save(workout)
        return workout
    }

    private func container(_ url: URL) throws -> ModelContainer {
        try ModelContainer(for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            SmartWorkoutSettingsRecord.self, SmartDailyVariantRecord.self, configurations: ModelConfiguration(url: url))
    }
}
