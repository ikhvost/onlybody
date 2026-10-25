import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct RestTimerTests {
    @Test func finishesUsingElapsedTimeAfterBackgroundGap() async {
        let time = ManualWorkoutTimeSource()
        var finishes = 0
        let timer = RestTimer(time: time, onFinished: { finishes += 1 })
        timer.start(seconds: 90, nextExercise: "Pull-Ups")
        #expect(timer.isActive)
        #expect(timer.nextExerciseName == "Pull-Ups")
        await time.waitForSleepers(1)
        #expect(time.sleeperCount == 1)
        time.advance(seconds: 95)
        await time.waitForSleepers(0)
        for _ in 0..<100 where timer.isActive { await Task.yield() }
        #expect(timer.remainingSeconds == 0)
        #expect(!timer.isActive)
        #expect(finishes == 1)
        time.advance(seconds: 120)
        for _ in 0..<100 { await Task.yield() }
        #expect(finishes == 1)
    }

    @Test func restartingCancelsPreviousCountdown() async {
        let time = ManualWorkoutTimeSource()
        var finishes = 0
        let timer = RestTimer(time: time, onFinished: { finishes += 1 })
        timer.start(seconds: 60)
        await time.waitForSleepers(1)
        timer.start(seconds: 30)
        for _ in 0..<100 { await Task.yield() }
        #expect(time.sleeperCount == 1)
        time.advance(seconds: 5)
        for _ in 0..<100 where timer.remainingSeconds == 30 { await Task.yield() }
        #expect(timer.remainingSeconds == 25)
        #expect(finishes == 0)
        timer.skip()
        await time.waitForSleepers(0)
        time.advance(seconds: 120)
        #expect(timer.remainingSeconds == 0)
        #expect(!timer.isActive)
        #expect(timer.nextExerciseName.isEmpty)
        #expect(finishes == 0)
    }

    @Test(arguments: [0, -1, -100])
    func nonpositiveDurationIsInactive(seconds: Int) {
        var finishes = 0
        let timer = RestTimer(time: ManualWorkoutTimeSource(), onFinished: { finishes += 1 })
        timer.start(seconds: seconds)
        #expect(!timer.isActive)
        #expect(timer.remainingSeconds == 0)
        #expect(finishes == 0)
    }

    @Test func onlyTheReplacementCountdownCanFinish() async {
        let time = ManualWorkoutTimeSource()
        var finishes = 0
        let timer = RestTimer(time: time, onFinished: { finishes += 1 })
        timer.start(seconds: 5)
        await time.waitForSleepers(1)
        timer.start(seconds: 20)
        for _ in 0..<100 { await Task.yield() }
        time.advance(seconds: 5)
        for _ in 0..<100 where timer.remainingSeconds == 20 { await Task.yield() }
        #expect(finishes == 0)
        await time.waitForSleepers(1)
        time.advance(seconds: 15)
        for _ in 0..<100 where timer.isActive { await Task.yield() }
        #expect(!timer.isActive)
        #expect(finishes == 1)
    }
}
