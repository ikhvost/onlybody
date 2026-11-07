import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartDailyPlannerTests {
    @Test func persistedDayWinsAcrossRelaunchButDateAndRevisionCreateNewKeys() async throws {
        let repository = MockSmartDailyVariantRepository()
        let date = Date(timeIntervalSince1970: 1_762_041_600)
        let workout = WorkoutSnapshot()
        var settings = SmartWorkoutSettings(configuration: SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"]))
        let planner = SmartDailyPlanner(variants: repository)
        let original = SmartDailyVariant(workoutID: workout.id, localDay: SmartPlanningClock().localDay(at: date),
            settingsRevision: settings.revision, items: [WorkoutItemSnapshot(targetReps: 17)], estimatedSeconds: 777,
            uncoveredNeeds: [], createdAt: date)
        try await repository.save(original)
        #expect(try await planner.resolve(workout: workout, settings: settings, exercises: [], date: date) == original)
        let tomorrow = try await planner.resolve(workout: workout, settings: settings, exercises: [], date: date.addingTimeInterval(86400))
        #expect(tomorrow.id != original.id)
        #expect(!tomorrow.uncoveredNeeds.isEmpty)
        settings.revision = UUID()
        let edited = try await planner.resolve(workout: workout, settings: settings, exercises: [], date: date)
        #expect(edited.id != original.id)
        repository.shouldThrow = true
        await #expect(throws: TestError.self) {
            try await planner.resolve(workout: workout, settings: settings, exercises: [], date: date)
        }
    }
}
