import Testing
@testable import onlybody

@MainActor
struct MovementDetailViewModelTests {
    @Test
    func setFrequencyUpdatesExerciseAndPersists() async {
        let repository = MockExerciseRepository()
        let exercise = Exercise()
        exercise.frequencyPreference = "normal"

        let viewModel = MovementDetailViewModel(exercise: exercise, exercises: repository)
        await viewModel.setFrequency("more")

        #expect(viewModel.selectedFrequency == "more")
        #expect(exercise.frequencyPreference == "more")
        #expect(repository.savedExercises.count == 1)
        #expect(repository.savedExercises.first?.frequencyPreference == "more")
    }
}
