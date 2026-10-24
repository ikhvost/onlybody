import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct ExerciseHistoryViewModelTests {
    @Test func showsAllCompletedMatchingSessionsNewestFirst() async {
        let repo = MockSessionRepository()
        let completed = SessionItemSnapshot(order: 1, exerciseName: "Squats", setReps: [12, 8], weightKg: 2.5)
        let repeated = SessionItemSnapshot(order: 0, exerciseName: "Squats", setReps: [6], weightKg: 5)
        let skipped = SessionItemSnapshot(exerciseName: "Squats", setReps: [])
        let other = SessionItemSnapshot(exerciseName: "Jump Squats", setReps: [20])
        let older = SessionSnapshot(date: Date(timeIntervalSince1970: 10), workoutName: "Legs", items: [completed])
        let newer = SessionSnapshot(date: Date(timeIntervalSince1970: 20), workoutName: "Full Body", items: [completed, other, skipped, repeated])
        repo.stubbedSessions = [older, SessionSnapshot(items: [skipped, other]), newer]
        let vm = ExerciseHistoryViewModel(exerciseName: "Squats", sessions: repo)

        await vm.load()

        #expect(vm.entries.map(\.id) == [newer.id, older.id])
        #expect(vm.entries[0].items == [repeated, completed])
        #expect(vm.entries[0].date == newer.date)
        #expect(vm.entries[0].workoutName == "Full Body")
        #expect(vm.entries[0].items.map(\.weightKg) == [5, 2.5])
        #expect(vm.entries[0].totalReps == 26)
        #expect(vm.entries[0].totalSets == 3)
        #expect(repo.savedSessions.isEmpty)
        #expect(!vm.isLoading)
    }

    @Test func unknownExerciseAndSkippedSetsHaveEmptyHistory() async {
        let repo = MockSessionRepository()
        repo.stubbedSessions = [SessionSnapshot(items: [SessionItemSnapshot(exerciseName: "Squats")])]
        for name in ["Squats", "Unknown"] {
            let vm = ExerciseHistoryViewModel(exerciseName: name, sessions: repo)
            await vm.load()
            #expect(vm.entries.isEmpty)
            #expect(vm.errorMessage == nil)
        }
    }

    @Test func retainsZeroRepSetsAndUnknownHistoricalWeight() async {
        let repo = MockSessionRepository()
        repo.stubbedSessions = [SessionSnapshot(items: [SessionItemSnapshot(exerciseName: "Plank", setReps: [0])])]
        let vm = ExerciseHistoryViewModel(exerciseName: "Plank", sessions: repo)
        await vm.load()
        #expect(vm.entries.first?.totalSets == 1)
        #expect(vm.entries.first?.totalReps == 0)
        #expect(vm.entries.first?.items.first?.weightKg == nil)
    }

    @Test func retryAfterFailureLoadsHistoryAndRefreshDoesNotDuplicateEntries() async {
        let repo = MockSessionRepository()
        repo.shouldThrow = true
        let vm = ExerciseHistoryViewModel(exerciseName: "Squats", sessions: repo)
        await vm.load()
        #expect(vm.errorMessage != nil)
        #expect(!vm.isLoading)
        repo.shouldThrow = false
        repo.stubbedSessions = [SessionSnapshot(items: [SessionItemSnapshot(exerciseName: "Squats", setReps: [10])])]
        await vm.load()
        await vm.load()
        #expect(vm.errorMessage == nil)
        #expect(vm.entries.count == 1)
        #expect(vm.entries.first?.totalReps == 10)
        #expect(repo.savedSessions.isEmpty)
    }

    @Test func perSetWeightNeverInfersMissingHistoryFromExerciseWeight() {
        let legacy = SessionItemSnapshot(setReps: [12, 10], weightKg: 5)
        #expect(legacy.weightForSet(at: 0) == nil)
        let recorded = SessionItemSnapshot(setReps: [12, 10, 8], setWeightsKg: [0, 2.5, 5])
        #expect(recorded.weightForSet(at: 0) == 0)
        #expect(recorded.weightForSet(at: 1) == 2.5)
        #expect(recorded.weightForSet(at: 2) == 5)
        #expect(recorded.weightForSet(at: 3) == nil)
        #expect(recorded.weightForSet(at: -1) == nil)
    }

}
