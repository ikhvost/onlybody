import Foundation
import SwiftData
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct ScreenshotStoreFixtureTests {
    @Test func demonstrationHistoryUsesCatalogExercisesAndDoesNotDuplicateOnRelaunch() async throws {
        let store = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(store)
        let seed = try #require(Bundle.main.url(forResource: "default", withExtension: "store"))
        for snapshot in try BundledExerciseCatalog.load(from: seed) {
            let exercise = Exercise()
            exercise.name = snapshot.name
            exercise.primaryMuscle = snapshot.primaryMuscle
            context.insert(exercise)
        }
        try context.save()
        let product = AppConfiguration.current.displayName
        let today = Date.now
        try ScreenshotStoreFixture.populate(store, product: product, language: "uk", today: today)
        let workouts = try context.fetch(FetchDescriptor<Workout>())
        #expect(workouts.count == 4)
        #expect(workouts.allSatisfy { $0.items?.count == 4 })
        #expect(workouts.contains { $0.name == "Верх тіла" })
        let sessions = try await SwiftDataSessionRepository(context: context).allSessions()
        #expect(sessions.count == 55)
        #expect(sessions.allSatisfy { $0.items.count == 4 && $0.items.allSatisfy { $0.setReps.count == 3 } })
        #expect(StreakCalculator().calculate(sessions: sessions, today: today).current == 3)
        try ScreenshotStoreFixture.populate(store, product: product, language: "en", today: today)
        #expect(try context.fetchCount(FetchDescriptor<Workout>()) == 4)
        #expect(try context.fetchCount(FetchDescriptor<Session>()) == 55)
        #expect(try context.fetchCount(FetchDescriptor<SessionItem>()) == 220)
    }

    @Test func screenshotFixturePreservesExistingWorkouts() throws {
        let store = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = ModelContext(store)
        let original = Workout()
        original.name = "Existing"
        context.insert(original)
        try context.save()
        try ScreenshotStoreFixture.populate(store, product: AppConfiguration.current.displayName, language: "en")
        #expect(try context.fetchCount(FetchDescriptor<Workout>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<Session>()) == 0)
        #expect(original.name == "Existing")
    }
}
