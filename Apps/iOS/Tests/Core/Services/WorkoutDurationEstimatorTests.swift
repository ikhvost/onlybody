import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

struct WorkoutDurationEstimatorTests {
    @Test func countsRepetitionsAndRestAfterEverySet() {
        let estimate = WorkoutDurationEstimator()
        #expect(estimate.seconds(sets: 3, reps: 8, restSeconds: 60) == 252)
        #expect(estimate.seconds(sets: 3, reps: 12, restSeconds: 60) == 288)
        #expect(estimate.seconds(sets: 1, reps: 8, restSeconds: 0) == 24)
    }

    @Test func emptyAndOverflowingPlansAreSafe() {
        let estimate = WorkoutDurationEstimator()
        #expect(estimate.seconds(sets: 0, reps: Int.max, restSeconds: 60) == 0)
        #expect(estimate.seconds(sets: Int.max, reps: 12, restSeconds: 60) == Int.max)
        #expect(estimate.budget(minutes: Int.max) == Int.max)
        #expect(estimate.budget(minutes: -1) == 0)
        #expect(estimate.adding(1, to: Int.max) == Int.max)
    }
}
