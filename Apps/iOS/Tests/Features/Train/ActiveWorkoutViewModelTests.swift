import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct ActiveWorkoutViewModelTests {
    private func model(sets: Int = 2) async -> (ActiveWorkoutViewModel, MockWorkoutRepository, MockSessionRepository) {
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [WorkoutSnapshot(name: "Training", items: [
            WorkoutItemSnapshot(order: 0, sets: sets, restSeconds: 45, exercise: ExerciseSnapshot(name: "A")),
            WorkoutItemSnapshot(order: 1, sets: sets, restSeconds: 60, exercise: ExerciseSnapshot(name: "B")),
            WorkoutItemSnapshot(order: 2, sets: sets, restSeconds: 90, exercise: ExerciseSnapshot(name: "C"))
        ])]
        let sessions = MockSessionRepository()
        let vm = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workouts.stubbedWorkouts[0].id,
                                        time: ManualWorkoutTimeSource())
        await vm.load()
        return (vm, workouts, sessions)
    }

    @Test func preparationDoesNotStartOrChangeTemplateAndStartsInEditedOrder() async {
        let (vm, workouts, _) = await model()
        defer { vm.cleanup() }
        let original = workouts.stubbedWorkouts[0]
        let first = vm.items[0].id
        let second = vm.items[1].id
        vm.moveExercise(second, to: first)
        vm.replaceExercise(second, with: ExerciseSnapshot(name: "Replacement"))
        #expect(!vm.hasStarted)
        #expect(vm.showsExerciseList)
        #expect(vm.elapsedSeconds == 0)
        #expect(workouts.savedWorkouts.isEmpty)
        #expect(workouts.stubbedWorkouts[0] == original)
        vm.beginSession()
        #expect(vm.currentItemID == second)
        #expect(vm.viewedItemID == second)
        #expect(!vm.showsExerciseList)
        #expect(vm.items[0].sets == 2)
        #expect(vm.items[0].restSeconds == 60)
    }

    @Test func arbitraryNavigationAndSetsDoNotChangeCurrentExercise() async {
        let (vm, _, _) = await model()
        defer { vm.cleanup() }
        vm.beginSession()
        let current = vm.currentItemID
        let other = vm.items[1].id
        vm.showExercise(other)
        vm.toggleSet(WorkoutSetID(itemID: other, index: 1))
        vm.showList()
        await vm.load()
        #expect(vm.currentItemID == current)
        #expect(vm.viewedItemID == other)
        #expect(vm.completedCount(for: other) == 1)
        #expect(vm.restTimer.remainingSeconds == 60)
        vm.resume()
        #expect(vm.viewedItemID == current)
    }

    @Test func completedRowsRemainEditableAndSurviveReorderAndUndo() async {
        let (vm, _, sessions) = await model()
        defer { vm.cleanup() }
        vm.beginSession()
        let first = vm.items[0].id
        let key = WorkoutSetID(itemID: first, index: 0)
        vm.enterWeight("25", for: key)
        vm.toggleSet(key)
        vm.enterWeight("30", for: key)
        vm.enterReps("9", for: key)
        vm.moveExercise(first, to: vm.items[2].id)
        #expect(vm.currentItemID == first)
        #expect(vm.row(key).weightKg == 30)
        #expect(vm.restTimer.remainingSeconds == 45)
        #expect(!vm.canReplace(first))
        vm.replaceExercise(first, with: ExerciseSnapshot(name: "Forbidden"))
        #expect(vm.items.last?.exercise?.name == "A")
        vm.toggleSet(key)
        #expect(vm.canReplace(first))
        #expect(vm.row(key).weightKg == 30)
        #expect(!vm.restTimer.isActive)
        vm.toggleSet(key)
        await vm.endSession()
        #expect(sessions.savedSessions.first?.items.last?.setReps == [9])
        #expect(sessions.savedSessions.first?.items.last?.setWeightsKg == [30])
    }

    @Test func advancementSkipsCompletedAndWrapsAroundReorderedExercises() async {
        let (vm, _, _) = await model(sets: 1)
        defer { vm.cleanup() }
        vm.beginSession()
        let first = vm.items[0].id
        let second = vm.items[1].id
        let third = vm.items[2].id
        vm.showExercise(second)
        vm.toggleSet(WorkoutSetID(itemID: second, index: 0))
        vm.showExercise(first)
        vm.moveExercise(first, to: third)
        vm.toggleSet(WorkoutSetID(itemID: first, index: 0))
        #expect(vm.currentItemID == third)
        #expect(vm.viewedItemID == third)
        #expect(vm.restTimer.remainingSeconds == 45)
    }

    @Test func lastCheckDoesNotSaveAndUndoReopensQueue() async {
        let (vm, _, sessions) = await model(sets: 1)
        defer { vm.cleanup() }
        vm.beginSession()
        for item in vm.items { vm.toggleSet(WorkoutSetID(itemID: item.id, index: 0)) }
        #expect(vm.allSetsCompleted)
        #expect(vm.showsExerciseList)
        #expect(!vm.isComplete)
        #expect(sessions.savedSessions.isEmpty)
        let key = WorkoutSetID(itemID: vm.items[0].id, index: 0)
        vm.enterReps("8", for: key)
        vm.toggleSet(key)
        #expect(!vm.allSetsCompleted)
        #expect(vm.currentItemID == key.itemID)
        vm.toggleSet(key)
        await vm.endSession()
        await vm.retrySave()
        #expect(sessions.savedSessions.count == 1)
        #expect(sessions.savedSessions[0].items[0].setReps == [8])
    }

    @Test func replacementClearsDraftInputsAndKeepsPlan() async {
        let (vm, _, _) = await model()
        defer { vm.cleanup() }
        let item = vm.items[0]
        let key = WorkoutSetID(itemID: item.id, index: 1)
        vm.enterWeight("10", for: key)
        vm.enterReps("8", for: key)
        vm.replaceExercise(item.id, with: ExerciseSnapshot(name: "New"))
        #expect(vm.items[0].id == item.id)
        #expect(vm.items[0].targetReps == item.targetReps)
        #expect(vm.items[0].sets == item.sets)
        #expect(vm.row(key).weightKg == 0)
        #expect(vm.row(key).reps == item.targetReps)
        #expect(!vm.showsWeight)
    }

    @Test func duplicateNamesKeepIndependentResultsAndNonconsecutiveSetsSaveInOrder() async {
        let (vm, _, sessions) = await model(sets: 3)
        defer { vm.cleanup() }
        vm.replaceExercise(vm.items[1].id, with: vm.items[0].exercise ?? ExerciseSnapshot())
        vm.beginSession()
        for (index, item) in vm.items.prefix(2).enumerated() {
            let key = WorkoutSetID(itemID: item.id, index: 2 - index)
            vm.enterWeight(String(20 + index * 10), for: key)
            vm.toggleSet(key)
        }
        await vm.endSession()
        #expect(sessions.savedSessions[0].items[0].setWeightsKg == [20])
        #expect(sessions.savedSessions[0].items[1].setWeightsKg == [30])
    }

    @Test func missingAndFailedLoadsRemainRecoverable() async {
        let workouts = MockWorkoutRepository()
        let vm = ActiveWorkoutViewModel(workouts: workouts, sessions: MockSessionRepository(), workoutId: UUID())
        await vm.load()
        #expect(vm.errorMessage != nil)
        vm.beginSession()
        #expect(!vm.hasStarted)
        workouts.shouldThrow = true
        await vm.load()
        #expect(vm.errorMessage != nil)
    }
}
