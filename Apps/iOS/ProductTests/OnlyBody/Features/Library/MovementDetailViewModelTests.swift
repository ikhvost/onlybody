import Testing
@testable import onlybody

@MainActor
struct MovementDetailViewModelTests {
    @Test func detailsExposeCatalogDifficulty() {
        var exercise = ExerciseSnapshot()
        exercise.name = "Archer Push-Ups"
        let viewModel = MovementDetailViewModel(exercise: exercise)
        #expect(viewModel.exercise.difficulty == .advanced)
        #expect(viewModel.exercise == exercise)
    }

    @Test func unknownExerciseHasNoInventedDifficulty() {
        let viewModel = MovementDetailViewModel(exercise: ExerciseSnapshot())
        #expect(viewModel.exercise.difficulty == .unrated)
    }
}
