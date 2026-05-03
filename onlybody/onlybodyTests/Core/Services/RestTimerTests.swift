import Foundation
import Testing
@testable import onlybody

@MainActor
struct RestTimerTests {

    @Test
    func startSetsRemainingSecondsAndMarksActive() {
        let timer = RestTimer()
        timer.start(seconds: 90, nextExercise: "Pull-Ups")

        #expect(timer.remainingSeconds == 90)
        #expect(timer.isActive)
        #expect(timer.nextExerciseName == "Pull-Ups")
    }

    @Test
    func startWithoutNextExerciseSetsEmptyName() {
        let timer = RestTimer()
        timer.start(seconds: 30)

        #expect(timer.nextExerciseName == "")
        #expect(timer.isActive)
    }

    @Test
    func skipStopsTimerAndResetsState() {
        let timer = RestTimer()
        timer.start(seconds: 60, nextExercise: "Squats")
        timer.skip()

        #expect(timer.remainingSeconds == 0)
        #expect(!timer.isActive)
    }

    @Test
    func autoCompleteDeactivatesWhenCountdownReachesZero() async {
        let timer = RestTimer()
        timer.start(seconds: 1)

        #expect(timer.isActive)

        while timer.isActive {
            await Task.yield()
        }

        #expect(!timer.isActive)
        #expect(timer.remainingSeconds == 0)
    }

    @Test
    func skipDuringSleepDoesNotProduceNegativeRemainingSeconds() async {
        let timer = RestTimer()
        timer.start(seconds: 60)

        await Task.yield()

        timer.skip()

        await Task.yield()
        await Task.yield()

        #expect(timer.remainingSeconds == 0)
        #expect(!timer.isActive)
    }

    @Test
    func startingNewCountdownCancelsPrevious() async {
        let timer = RestTimer()
        timer.start(seconds: 60)

        #expect(timer.remainingSeconds == 60)

        timer.start(seconds: 30)

        #expect(timer.remainingSeconds == 30)
        #expect(timer.isActive)
    }
}
