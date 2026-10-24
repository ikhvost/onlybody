import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SessionPersistenceRegressionTests {
    @Test func repeatedFinishAndRetryWriteOneIdentity() async throws {
        let workouts = MockWorkoutRepository()
        let sessions = MockSessionRepository()
        var item = WorkoutItemSnapshot()
        item.sets = 1
        item.exercise = ExerciseSnapshot(name: "Push-Ups")
        let workout = WorkoutSnapshot(name: "Test", items: [item])
        workouts.stubbedWorkouts = [workout]
        let time = ManualWorkoutTimeSource()
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id, time: time)
        await model.load()
        time.advance(seconds: 125)
        sessions.shouldThrow = true
        model.markSetDone()
        await model.saveTask?.value
        #expect(model.saveState == .failed)
        #expect(model.elapsedSeconds == 125)
        sessions.shouldThrow = false
        await model.retrySave()
        model.markSetDone()
        await model.endSession()
        await model.retrySave()
        #expect(sessions.savedSessions.count == 1)
        #expect(model.saveState == .saved)
        #expect(sessions.savedSessions.first?.durationSeconds == 125)
        #expect(sessions.savedSessions.first?.items.first?.setReps == [12])
        model.cleanup()
    }

    @Test func failedEditLeavesOriginalValueUntouched() async {
        let workouts = MockWorkoutRepository()
        workouts.shouldThrow = true
        let original = WorkoutSnapshot(name: "Original", mode: "manual", items: [WorkoutItemSnapshot()])
        let model = SessionBuilderViewModel(workouts: workouts, exercises: MockExerciseRepository(), workout: original)
        model.name = "Changed"
        #expect(await model.save() == false)
        #expect(original.name == "Original")
        #expect(original.items.count == 1)
        #expect(workouts.savedWorkouts.isEmpty)
    }

    @Test func cancellationDoesNotAdvanceElapsedSeconds() async {
        let workouts = MockWorkoutRepository()
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot()])
        workouts.stubbedWorkouts = [workout]
        let time = ManualWorkoutTimeSource()
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: MockSessionRepository(), workoutId: workout.id, time: time)
        await model.load()
        await time.waitForSleepers(1)
        model.cleanup()
        await time.waitForSleepers(0)
        time.advance(seconds: 100)
        #expect(model.elapsedSeconds == 0)
    }
    @Test func editingPreservesWorkoutAndMovementIdentities() async throws {
        let workouts = MockWorkoutRepository()
        let exercise = ExerciseSnapshot(name: "Push-Up")
        let original = WorkoutSnapshot(name: "Original", mode: "manual", items: [WorkoutItemSnapshot(exercise: exercise)])
        let model = SessionBuilderViewModel(workouts: workouts, exercises: MockExerciseRepository(), workout: original)
        model.setSets(5, forMovement: try #require(model.movements.first).id)
        #expect(await model.save())
        let saved = try #require(workouts.savedWorkouts.first)
        #expect(saved.id == original.id)
        #expect(saved.items.first?.id == original.items.first?.id)
        #expect(saved.items.first?.sets == 5)
        #expect(original.items.first?.sets == 3)
    }
    @Test func concurrentEarlyFinishCallsAwaitTheSameCommit() async throws {
        let workouts = MockWorkoutRepository()
        let sessions = MockSessionRepository()
        sessions.suspendSaves = true
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot()])
        workouts.stubbedWorkouts = [workout]
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id)
        await model.load()
        var completions = 0
        let first = Task { await model.endSession(); completions += 1 }
        for _ in 0..<1_000 where !sessions.isWaitingToSave { await Task.yield() }
        try #require(sessions.isWaitingToSave)
        let second = Task { await model.endSession(); completions += 1 }
        for _ in 0..<100 { await Task.yield() }
        #expect(completions == 0)
        #expect(model.saveState == .saving)
        sessions.resumeSave()
        await first.value
        await second.value
        #expect(completions == 2)
        #expect(sessions.savedSessions.count == 1)
        #expect(model.saveState == .saved)
        model.cleanup()
    }
}
