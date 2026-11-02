import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct TrainViewModelTests {
    @Test
    func loadPopulatesWorkouts() async {
        let workoutRepo = MockWorkoutRepository()

        var fullBody = WorkoutSnapshot()
        fullBody.name = "Full Body"
        fullBody.scheduledDays = ["Mon", "Wed", "Fri"]

        var upperBody = WorkoutSnapshot()
        upperBody.name = "Upper Body"
        upperBody.scheduledDays = ["Tue", "Thu"]

        workoutRepo.stubbedWorkouts = [fullBody, upperBody]

        let viewModel = TrainViewModel(workouts: workoutRepo, appName: "OnlyBody")
        await viewModel.load()

        #expect(viewModel.workouts.count == 2)
        #expect(viewModel.workouts.map(\.name) == ["Full Body", "Upper Body"])
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test
    func todaysWorkoutsFiltersCorrectly() async {
        let workoutRepo = MockWorkoutRepository()

        let today = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][
            Calendar.current.component(.weekday, from: Date()) - 1
        ]

        var fullBody = WorkoutSnapshot()
        fullBody.name = "Full Body"
        fullBody.scheduledDays = [today, "Fri"]

        var upperBody = WorkoutSnapshot()
        upperBody.name = "Upper Body"
        upperBody.scheduledDays = ["Wed"]

        workoutRepo.stubbedWorkouts = [fullBody, upperBody]

        let viewModel = TrainViewModel(workouts: workoutRepo, appName: "OnlyBody")
        await viewModel.load()

        let todaysNames = viewModel.todaysWorkouts.map(\.name)
        #expect(todaysNames.contains("Full Body"))

        if today != "Wed" {
            #expect(!todaysNames.contains("Upper Body"))
        }
    }

    @Test
    func loadSetsErrorMessageWhenRepositoryFails() async {
        let workoutRepo = MockWorkoutRepository()
        workoutRepo.shouldThrow = true

        let viewModel = TrainViewModel(workouts: workoutRepo, appName: "OnlyBody")
        await viewModel.load()

        #expect(viewModel.workouts.isEmpty)
        #expect(viewModel.errorMessage == "Could not load workouts.")
        #expect(viewModel.isLoading == false)
    }

}
