import Foundation
import Testing
@testable import onlybody

@MainActor
struct TrainViewModelTests {
    @Test
    func loadPopulatesWorkouts() async {
        let workoutRepo = MockWorkoutRepository()
        let sessionRepo = MockSessionRepository()

        let fullBody = Workout()
        fullBody.name = "Full Body"
        fullBody.scheduledDays = ["Mon", "Wed", "Fri"]

        let upperBody = Workout()
        upperBody.name = "Upper Body"
        upperBody.scheduledDays = ["Tue", "Thu"]

        workoutRepo.stubbedWorkouts = [fullBody, upperBody]

        let viewModel = TrainViewModel(workouts: workoutRepo, sessions: sessionRepo)
        await viewModel.load()

        #expect(viewModel.workouts.count == 2)
        #expect(viewModel.workouts.map(\.name) == ["Full Body", "Upper Body"])
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test
    func todaysWorkoutsFiltersCorrectly() async {
        let workoutRepo = MockWorkoutRepository()
        let sessionRepo = MockSessionRepository()

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

        let viewModel = TrainViewModel(workouts: workoutRepo, sessions: sessionRepo)
        await viewModel.load()

        let todaysNames = viewModel.todaysWorkouts.map(\.name)
        #expect(todaysNames.contains("Full Body"))

        if today != "Wed" {
            #expect(!todaysNames.contains("Upper Body"))
        }
    }

    @Test
    func deleteRemovesWorkout() async {
        let workoutRepo = MockWorkoutRepository()
        let sessionRepo = MockSessionRepository()

        let fullBody = Workout()
        fullBody.name = "Full Body"

        workoutRepo.stubbedWorkouts = [fullBody]

        let viewModel = TrainViewModel(workouts: workoutRepo, sessions: sessionRepo)
        await viewModel.load()

        #expect(viewModel.workouts.count == 1)

        await viewModel.delete(fullBody)

        #expect(viewModel.workouts.isEmpty)
        #expect(workoutRepo.deletedWorkouts.count == 1)
        #expect(workoutRepo.deletedWorkouts.first?.name == "Full Body")
    }

    @Test
    func loadSetsErrorMessageWhenRepositoryFails() async {
        let workoutRepo = MockWorkoutRepository()
        workoutRepo.shouldThrow = true
        let sessionRepo = MockSessionRepository()

        let viewModel = TrainViewModel(workouts: workoutRepo, sessions: sessionRepo)
        await viewModel.load()

        #expect(viewModel.workouts.isEmpty)
        #expect(viewModel.errorMessage == "Could not load workouts.")
        #expect(viewModel.isLoading == false)
    }

    @Test
    func deleteErrorSetsErrorMessage() async {
        let workoutRepo = MockWorkoutRepository()
        let sessionRepo = MockSessionRepository()

        let fullBody = Workout()
        fullBody.name = "Full Body"
        workoutRepo.stubbedWorkouts = [fullBody]

        let viewModel = TrainViewModel(workouts: workoutRepo, sessions: sessionRepo)
        await viewModel.load()
        #expect(viewModel.workouts.count == 1)
        #expect(viewModel.errorMessage == nil)

        workoutRepo.shouldThrow = true
        await viewModel.delete(fullBody)
        #expect(viewModel.errorMessage == "Could not delete workout.")
    }
}
