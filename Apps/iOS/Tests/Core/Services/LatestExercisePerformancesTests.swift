import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

struct LatestExercisePerformancesTests {
    @Test func newestCompletedExerciseWinsAcrossDifferentWorkouts() {
        let old = SessionSnapshot(date: Date(timeIntervalSince1970: 100), workoutName: "Old", items: [
            SessionItemSnapshot(exerciseName: "Press", setReps: [12], setWeightsKg: [40]),
            SessionItemSnapshot(exerciseName: "Row", setReps: [10], setWeightsKg: [30])
        ])
        let recent = SessionSnapshot(date: Date(timeIntervalSince1970: 200), workoutName: "Other workout", items: [
            SessionItemSnapshot(exerciseName: "Press", setReps: [8], setWeightsKg: [50])
        ])
        let empty = SessionSnapshot(date: Date(timeIntervalSince1970: 300), items: [SessionItemSnapshot(exerciseName: "Press")])
        let result = LatestExercisePerformances().items(in: [old, empty, recent])
        #expect(result["Press"]?.first?.setReps == [8])
        #expect(result["Press"]?.first?.setWeightsKg == [50])
        #expect(result["Row"]?.first?.setWeightsKg == [30])
    }

    @Test func duplicateOccurrencesKeepTheirSavedOrder() {
        let first = SessionItemSnapshot(order: 0, exerciseName: "Press", setReps: [8], setWeightsKg: [50])
        let second = SessionItemSnapshot(order: 2, exerciseName: "Press", setReps: [6], setWeightsKg: [55])
        let session = SessionSnapshot(items: [second, first])
        #expect(LatestExercisePerformances().items(in: [session])["Press"] == [first, second])
    }
}
