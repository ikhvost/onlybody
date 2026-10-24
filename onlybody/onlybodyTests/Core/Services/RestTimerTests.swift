import Testing
@testable import onlybody

@MainActor
struct RestTimerTests {
    @Test func finishesUsingElapsedTimeAfterBackgroundGap() async {
        let time = ManualWorkoutTimeSource()
        let timer = RestTimer(time: time)
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
    }

    @Test func restartingCancelsPreviousCountdown() async {
        let time = ManualWorkoutTimeSource()
        let timer = RestTimer(time: time)
        timer.start(seconds: 60)
        await time.waitForSleepers(1)
        timer.start(seconds: 30)
        for _ in 0..<100 { await Task.yield() }
        #expect(time.sleeperCount == 1)
        time.advance(seconds: 5)
        for _ in 0..<100 where timer.remainingSeconds == 30 { await Task.yield() }
        #expect(timer.remainingSeconds == 25)
        timer.skip()
        await time.waitForSleepers(0)
        time.advance(seconds: 120)
        #expect(timer.remainingSeconds == 0)
        #expect(!timer.isActive)
        #expect(timer.nextExerciseName.isEmpty)
    }

    @Test(arguments: [0, -1, -100])
    func nonpositiveDurationIsInactive(seconds: Int) {
        let timer = RestTimer(time: ManualWorkoutTimeSource())
        timer.start(seconds: seconds)
        #expect(!timer.isActive)
        #expect(timer.remainingSeconds == 0)
    }
}
