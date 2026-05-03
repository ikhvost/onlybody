import Foundation
import Testing
@testable import onlybody

@MainActor
struct TrainViewModelTests {
    @Test
    func loadPopulatesWorkouts() async {
        let workoutRepo = MockWorkoutRepository()

        let fullBody = Workout()
        fullBody.name = "Full Body"
        fullBody.scheduledDays = ["Mon", "Wed", "Fri"]

        let upperBody = Workout()
        upperBody.name = "Upper Body"
        upperBody.scheduledDays = ["Tue", "Thu"]

        workoutRepo.stubbedWorkouts = [fullBody, upperBody]

        let viewModel = TrainViewModel(workouts: workoutRepo)
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

        let fullBody = Workout()
        fullBody.name = "Full Body"
        fullBody.scheduledDays = [today, "Fri"]

        let upperBody = Workout()
        upperBody.name = "Upper Body"
        upperBody.scheduledDays = ["Wed"]

        workoutRepo.stubbedWorkouts = [fullBody, upperBody]

        let viewModel = TrainViewModel(workouts: workoutRepo)
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

        let viewModel = TrainViewModel(workouts: workoutRepo)
        await viewModel.load()

        #expect(viewModel.workouts.isEmpty)
        #expect(viewModel.errorMessage == "Could not load workouts.")
        #expect(viewModel.isLoading == false)
    }

}
