import Foundation
import SwiftData
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutDeletionTests {
    @Test func deletionSurvivesReopenAndPreservesExerciseHistory() async throws {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "test.store")
        let container = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(url: url))
        let exercises = SwiftDataExerciseRepository(context: ModelContext(container))
        let workouts = SwiftDataWorkoutRepository(context: ModelContext(container))
        let sessions = SwiftDataSessionRepository(context: ModelContext(container))
        let exercise = ExerciseSnapshot(name: "Standard Push-Ups")
        try await exercises.save(exercise)
        let workout = WorkoutSnapshot(name: "My session", items: [WorkoutItemSnapshot(exercise: exercise)])
        try await workouts.save(workout)
        let old = SessionSnapshot(
            date: Date(timeIntervalSince1970: 100), workoutName: workout.name,
            items: [SessionItemSnapshot(exerciseName: exercise.name, setReps: [12, 8], setWeightsKg: [0, 5])])
        try await sessions.save(old)
        try await workouts.delete(by: workout.id)
        try await workouts.delete(by: workout.id)

        let reopened = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(url: url))
        let context = ModelContext(reopened)
        #expect(try context.fetchCount(FetchDescriptor<Workout>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<WorkoutItem>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Exercise>()) == 1)
        let saved = SwiftDataSessionRepository(context: context)
        #expect(try await saved.allSessions() == [old])
        let newWorkout = WorkoutSnapshot(name: "New session", items: [WorkoutItemSnapshot(exercise: exercise)])
        try await SwiftDataWorkoutRepository(context: ModelContext(reopened)).save(newWorkout)
        let recent = SessionSnapshot(
            date: Date(timeIntervalSince1970: 200), workoutName: newWorkout.name,
            items: [SessionItemSnapshot(exerciseName: exercise.name, setReps: [10], setWeightsKg: [2.5])])
        try await saved.save(recent)
        let history = ExerciseHistoryViewModel(exerciseName: exercise.name, sessions: saved)
        await history.load()
        #expect(history.entries.map(\.id) == [recent.id, old.id])
        #expect(history.entries.last?.items.first?.setReps == [12, 8])
        #expect(history.entries.last?.items.first?.setWeightsKg == [0, 5])
        let log = LogViewModel(sessions: saved)
        await log.load()
        #expect(log.stats.total == 2)
    }

    @Test func builderDeletionTargetsOnlyExistingTemplateAndHandlesFailure() async {
        let workout = WorkoutSnapshot(name: "My session")
        let repository = MockWorkoutRepository()
        repository.stubbedWorkouts = [workout]
        let model = SessionBuilderViewModel(workouts: repository, exercises: MockExerciseRepository(), workout: workout)
        repository.shouldThrow = true
        #expect(await model.deleteWorkout() == false)
        #expect(repository.deletedIDs.isEmpty)
        #expect(model.errorMessage != nil)
        #expect(!model.isSaving)
        repository.shouldThrow = false
        #expect(await model.deleteWorkout())
        #expect(repository.deletedIDs == [workout.id])
        #expect(model.errorMessage == nil)
        let draft = SessionBuilderViewModel(workouts: repository, exercises: MockExerciseRepository())
        #expect(await draft.deleteWorkout() == false)
        #expect(repository.deletedIDs == [workout.id])
    }
}
