import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutOverviewViewModelTests {
    @Test func loadsByIdentityAndRefreshesAfterEditing() async {
        let repository = MockWorkoutRepository()
        var workout = WorkoutSnapshot(name: "First", items: [WorkoutItemSnapshot(sets: 2)])
        repository.stubbedWorkouts = [WorkoutSnapshot(name: "Other"), workout]
        let model = WorkoutOverviewViewModel(workoutID: workout.id, workouts: repository)
        await model.load()
        #expect(model.workout?.name == "First")
        #expect(model.summary.totalSets == 2)
        workout.name = "Edited"
        workout.items[0].sets = 4
        repository.stubbedWorkouts = [workout]
        await model.load()
        #expect(model.workout?.name == "Edited")
        #expect(model.summary.totalSets == 4)
        repository.stubbedWorkouts = []
        await model.load()
        #expect(model.workout == nil)
        #expect(repository.savedWorkouts.isEmpty)
    }

    @Test func failedLoadCanBeRetried() async {
        let repository = MockWorkoutRepository()
        let workout = WorkoutSnapshot()
        let model = WorkoutOverviewViewModel(workoutID: workout.id, workouts: repository)
        repository.shouldThrow = true
        await model.load()
        #expect(model.errorMessage != nil)
        #expect(!model.isLoading)
        repository.shouldThrow = false
        repository.stubbedWorkouts = [workout]
        await model.load()
        #expect(model.errorMessage == nil)
        #expect(model.workout?.id == workout.id)
    }
}
