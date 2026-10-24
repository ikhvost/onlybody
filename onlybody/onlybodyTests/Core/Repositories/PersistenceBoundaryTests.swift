import Foundation
import SwiftData
import Testing
@testable import onlybody

@MainActor
struct PersistenceBoundaryTests {
    private func container(url: URL? = nil) throws -> ModelContainer {
        let config = url.map { ModelConfiguration(url: $0) } ?? ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
                                  configurations: config)
    }

    @Test func failedReplacementRollsBackAndDetachedReadsStayUnchanged() async throws {
        let store = try container()
        let context = ModelContext(store)
        let exercises = SwiftDataExerciseRepository(context: context)
        let repository = SwiftDataWorkoutRepository(context: context)
        let exercise = ExerciseSnapshot(name: "Push-Up")
        try await exercises.save(exercise)
        let original = WorkoutSnapshot(name: "Original", durationMinutes: 35, restSeconds: 90, items: [WorkoutItemSnapshot(exercise: exercise)])
        try await repository.save(original)
        var changed = original
        changed.name = "Changed"
        changed.durationMinutes = 45
        changed.restSeconds = 60
        changed.items = [WorkoutItemSnapshot(exercise: ExerciseSnapshot(name: "Missing"))]
        await #expect(throws: PersistenceError.self) { try await repository.save(changed) }
        let restored = try #require(try await repository.workout(by: original.id))
        #expect(restored == original)
        #expect(!context.hasChanges)
        #expect(try context.fetchCount(FetchDescriptor<WorkoutItem>()) == 1)
        changed.items = [WorkoutItemSnapshot(sets: 5, exercise: exercise)]
        try await repository.save(changed)
        #expect(original.name == "Original")
        #expect(try context.fetchCount(FetchDescriptor<WorkoutItem>()) == 1)
        #expect(try await repository.workout(by: original.id)?.items.first?.sets == 5)
    }

    @Test func sessionSaveIsIdempotentAndMissingExerciseMapsToNil() async throws {
        let store = try container()
        let context = ModelContext(store)
        let sessions = SwiftDataSessionRepository(context: context)
        let session = SessionSnapshot(workoutName: "History", items: [SessionItemSnapshot(setReps: [12])])
        try await sessions.save(session)
        try await sessions.save(session)
        #expect(try await sessions.allSessions() == [session])
        #expect(try context.fetchCount(FetchDescriptor<SessionItem>()) == 1)
        let workouts = SwiftDataWorkoutRepository(context: context)
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot()])
        try await workouts.save(workout)
        #expect(try await workouts.workout(by: workout.id)?.items.first?.exercise == nil)
    }

    @Test func shippedSeedMigratesAndExistingHistoryReopens() async throws {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let seed = try #require(Bundle.main.url(forResource: "default", withExtension: "store"))
        let url = directory.appending(path: "default.store")
        try FileManager.default.copyItem(at: seed, to: url)
        // Open the shipped older seed schema, add history, then reopen through domain repositories.
        let sessionID = UUID()
        let workoutID = UUID()
        let count: Int
        do {
            let legacy = try container(url: url)
            let context = ModelContext(legacy)
            let exercises = try context.fetch(FetchDescriptor<Exercise>())
            count = exercises.count
            #expect(count > 0)
            let workout = Workout()
            workout.id = workoutID
            workout.name = "Existing workout"
            let item = WorkoutItem()
            item.exercise = exercises.first
            item.workout = workout
            workout.items = [item]
            context.insert(workout)
            let session = Session()
            session.id = sessionID
            session.workoutName = "Existing history"
            let sessionItem = SessionItem()
            sessionItem.setReps = [9, 8]
            session.items = [sessionItem]
            context.insert(session)
            try context.save()
        }
        let reopened = try container(url: url)
        let context = ModelContext(reopened)
        #expect(try await SwiftDataExerciseRepository(context: context).allExercises().count == count)
        let workout = try #require(try await SwiftDataWorkoutRepository(context: context).workout(by: workoutID))
        #expect(workout.name == "Existing workout")
        #expect(workout.items.first?.exercise != nil)
        let sessions = try await SwiftDataSessionRepository(context: context).allSessions()
        #expect(sessions.first?.id == sessionID)
        #expect(sessions.first?.items.first?.setReps == [9, 8])
        #expect(sessions.first?.items.first?.setWeightsKg == nil)
    }
}
