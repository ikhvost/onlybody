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

    @Test
    func setFrequencySkipsSaveWhenValueUnchanged() async {
        let repository = MockExerciseRepository()
        let exercise = Exercise()
        exercise.frequencyPreference = "more"

        let viewModel = MovementDetailViewModel(exercise: exercise, exercises: repository)
        await viewModel.setFrequency("more")

        #expect(viewModel.selectedFrequency == "more")
        #expect(repository.savedExercises.isEmpty)
    }

    @Test
    func setFrequencyRollsBackOnSaveError() async {
        let repository = MockExerciseRepository()
        repository.shouldThrow = true
        let exercise = Exercise()
        exercise.frequencyPreference = "normal"

        let viewModel = MovementDetailViewModel(exercise: exercise, exercises: repository)
        await viewModel.setFrequency("more")

        #expect(viewModel.selectedFrequency == "normal")
        #expect(exercise.frequencyPreference == "normal")
    }

    @Test
    func isSavingIsFalseAfterCompletion() async {
        let repository = MockExerciseRepository()
        let exercise = Exercise()

        let viewModel = MovementDetailViewModel(exercise: exercise, exercises: repository)
        #expect(viewModel.isSaving == false)

        await viewModel.setFrequency("more")

        #expect(viewModel.isSaving == false)
    }

    @Test
    func setFrequencyBlockedWhileSaving() async {
        let repository = MockExerciseRepository()
        let exercise = Exercise()

        let viewModel = MovementDetailViewModel(exercise: exercise, exercises: repository)
        #expect(viewModel.selectedFrequency == "normal")

        viewModel.isSaving = true
        await viewModel.setFrequency("more")

        #expect(viewModel.selectedFrequency == "normal")
        #expect(exercise.frequencyPreference == "normal")
        #expect(repository.savedExercises.isEmpty)

        viewModel.isSaving = false
        await viewModel.setFrequency("more")

        #expect(viewModel.selectedFrequency == "more")
        #expect(exercise.frequencyPreference == "more")
        #expect(repository.savedExercises.count == 1)
    }

    @Test
    func selectedFrequencyDefaultsToNormal() {
        let repository = MockExerciseRepository()
        let exercise = Exercise()

        let viewModel = MovementDetailViewModel(exercise: exercise, exercises: repository)

        #expect(viewModel.selectedFrequency == "normal")
    }
}
