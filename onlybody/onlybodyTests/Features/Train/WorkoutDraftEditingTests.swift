import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutDraftEditingTests {
    @Test(arguments: ["manual", "smart"])
    func orderAndReplacementSaveAtomicallyWithOriginalIdentities(mode: String) async throws {
        let exercises = [ExerciseSnapshot(name: "A"), ExerciseSnapshot(name: "B"), ExerciseSnapshot(name: "Replacement")]
        let original = WorkoutSnapshot(mode: mode, targetMuscleGroups: ["Chest"], items: [
            WorkoutItemSnapshot(order: 0, sets: 4, targetReps: 9, restSeconds: 90, exercise: exercises[0]),
            WorkoutItemSnapshot(order: 1, sets: 2, targetReps: 8, restSeconds: 30, exercise: exercises[1])
        ])
        let workouts = MockWorkoutRepository()
        let catalog = MockExerciseRepository()
        catalog.stubbedAllExercises = exercises
        let vm = SessionBuilderViewModel(workouts: workouts, exercises: catalog, workout: original)
        await vm.loadExercises()
        vm.moveMovement(original.items[1].id, to: original.items[0].id)
        vm.replaceMovement(original.items[1].id, with: exercises[2])
        #expect(vm.hasUnsavedChanges)
        #expect(workouts.savedWorkouts.isEmpty)
        #expect(original.items[1].exercise?.name == "B")
        #expect(await vm.save())
        let saved = try #require(workouts.savedWorkouts.first)
        #expect(saved.id == original.id)
        #expect(saved.items.map(\.id) == original.items.reversed().map(\.id))
        #expect(saved.items.map(\.order) == [0, 1])
        #expect(saved.items[0].exercise?.name == "Replacement")
        #expect(saved.items[0].sets == 2)
        #expect(saved.items[0].targetReps == 8)
        #expect(saved.items[0].restSeconds == 30)
    }

    @Test func replacementCatalogFailureCanBeRetriedWithoutLosingSessionResults() async {
        let workouts = MockWorkoutRepository()
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot()])
        workouts.stubbedWorkouts = [workout]
        let catalog = MockExerciseRepository()
        catalog.shouldThrow = true
        let vm = ActiveWorkoutViewModel(workouts: workouts, sessions: MockSessionRepository(), workoutId: workout.id, exercises: catalog)
        await vm.load()
        vm.beginSession()
        defer { vm.cleanup() }
        vm.toggleSet(vm.currentKey)
        await vm.loadReplacementExercises()
        #expect(vm.replacementError != nil)
        #expect(vm.completedSetCount == 1)
        catalog.shouldThrow = false
        catalog.stubbedAllExercises = [ExerciseSnapshot(name: "Replacement")]
        await vm.loadReplacementExercises()
        #expect(vm.replacementError == nil)
        #expect(vm.allExercises.count == 1)
        #expect(vm.completedSetCount == 1)
    }
}
