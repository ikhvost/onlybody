import Testing
@testable import onlybody

@MainActor
struct WorkoutDiscardTests {
    @Test func discardStopsTimersAndCannotLaterSaveCompletedSets() async {
        let time = ManualWorkoutTimeSource()
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot(sets: 2)])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id, time: time)
        await model.load()
        model.markSetDone()
        await time.waitForSleepers(2)
        time.advance(seconds: 10)
        #expect(model.discardSession())
        #expect(!model.restTimer.isActive)
        #expect(model.elapsedSeconds == 10)
        await time.waitForSleepers(0)
        time.advance(seconds: 60)
        model.markSetDone()
        await model.endSession()
        await model.retrySave()
        #expect(model.elapsedSeconds == 10)
        #expect(model.completedSets.count == 1)
        #expect(model.saveTask == nil)
        #expect(sessions.savedSessions.isEmpty)
        #expect(!model.discardSession())
    }

    @Test func discardBeforeAnySetsDoesNotCreateAnEmptySession() async {
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot()])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id)
        await model.load()
        #expect(model.discardSession())
        await model.endSession()
        #expect(sessions.savedSessions.isEmpty)
    }

    @Test func completedSessionCannotBeDiscardedWhileSaveIsInFlight() async {
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot(sets: 1)])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        sessions.suspendSaves = true
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id)
        await model.load()
        model.markSetDone()
        for _ in 0..<1_000 where !sessions.isWaitingToSave { await Task.yield() }
        #expect(sessions.isWaitingToSave)
        #expect(!model.discardSession())
        sessions.resumeSave()
        await model.saveTask?.value
        #expect(sessions.savedSessions.count == 1)
    }
}
