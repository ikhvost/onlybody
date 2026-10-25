import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutCueTests {
    @Test func timerUsesCurrentSoundPreferenceWithoutChangingCountdown() async {
        let time = ManualWorkoutTimeSource()
        let preferences = WorkoutPreferences()
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot(sets: 3, restSeconds: 5)])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        var cues = 0
        let model = ActiveWorkoutViewModel(
            workouts: workouts, sessions: MockSessionRepository(), workoutId: workout.id, time: time,
            preferences: preferences, playRestCue: { cues += 1 }
        )
        await model.load()
        model.markSetDone()
        await time.waitForSleepers(2)
        preferences.isTimerSoundEnabled = false
        time.advance(seconds: 5)
        for _ in 0..<100 where model.restTimer.isActive { await Task.yield() }
        #expect(!model.restTimer.isActive)
        #expect(model.currentSetIndex == 1)
        #expect(cues == 0)

        model.markSetDone()
        await time.waitForSleepers(2)
        preferences.isTimerSoundEnabled = true
        time.advance(seconds: 5)
        for _ in 0..<100 where model.restTimer.isActive { await Task.yield() }
        #expect(!model.restTimer.isActive)
        #expect(model.currentSetIndex == 2)
        #expect(cues == 1)
        model.cleanup()
    }

    @Test(arguments: [false, true])
    func naturalRestCompletionPlaysOneCue(betweenExercises: Bool) async {
        let time = ManualWorkoutTimeSource()
        let workout = WorkoutSnapshot(items: [
            WorkoutItemSnapshot(order: 0, sets: betweenExercises ? 1 : 2, restSeconds: 5),
            WorkoutItemSnapshot(order: 1, sets: 1, restSeconds: 5)
        ])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        var cues = 0
        let model = ActiveWorkoutViewModel(
            workouts: workouts, sessions: MockSessionRepository(), workoutId: workout.id, time: time,
            playRestCue: { cues += 1 }
        )
        await model.load()
        model.markSetDone()
        #expect(cues == 0)
        #expect(model.currentExerciseIndex == (betweenExercises ? 1 : 0))
        #expect(model.currentSetIndex == (betweenExercises ? 0 : 1))
        await time.waitForSleepers(2)
        time.advance(seconds: 5)
        for _ in 0..<100 where model.restTimer.isActive { await Task.yield() }
        #expect(!model.restTimer.isActive)
        #expect(cues == 1)
        model.cleanup()
    }

    @Test(arguments: ["skip", "cleanup", "discard", "finish"])
    func cancelledRestNeverPlaysACue(action: String) async {
        let time = ManualWorkoutTimeSource()
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot(sets: 2, restSeconds: 5)])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        var cues = 0
        var stops = 0
        let model = ActiveWorkoutViewModel(
            workouts: workouts, sessions: MockSessionRepository(), workoutId: workout.id, time: time,
            playRestCue: { cues += 1 }, stopRestCue: { stops += 1 }
        )
        await model.load()
        model.markSetDone()
        await time.waitForSleepers(2)
        stops = 0
        switch action {
        case "skip": model.restTimer.skip()
        case "cleanup": model.cleanup()
        case "discard": model.discardSession()
        default: await model.endSession()
        }
        time.advance(seconds: 10)
        for _ in 0..<100 { await Task.yield() }
        #expect(cues == 0)
        #expect(!model.restTimer.isActive)
        if action != "skip" { #expect(stops == 1) }
        model.cleanup()
    }
}
