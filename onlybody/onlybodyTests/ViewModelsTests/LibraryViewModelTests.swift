import Testing
@testable import onlybody

@MainActor
struct LibraryViewModelTests {
    @Test
    func loadPopulatesExercisesAndFiltersBySearchAndMuscle() async {
        let repository = MockExerciseRepository()

        let pushUps = Exercise()
        pushUps.name = "Push-Ups"
        pushUps.primaryMuscle = "Chest"

        let pullUps = Exercise()
        pullUps.name = "Pull-Ups"
        pullUps.primaryMuscle = "Back"

        repository.stubbedAllExercises = [pushUps, pullUps]

        let viewModel = LibraryViewModel(exercises: repository)
        await viewModel.load()

        #expect(viewModel.allExercises.count == 2)
        #expect(viewModel.errorMessage == nil)

        viewModel.searchText = "push"
        #expect(viewModel.filteredExercises.map(\.name) == ["Push-Ups"])

        viewModel.searchText = ""
        viewModel.selectedFilter = "Back"
        #expect(viewModel.filteredExercises.map(\.name) == ["Pull-Ups"])
    }

    @Test
    func filtersBySearchAndMuscleCombined() async {
        let repository = MockExerciseRepository()

        let pushUps = Exercise()
        pushUps.name = "Push-Ups"
        pushUps.primaryMuscle = "Chest"

        let pullUps = Exercise()
        pullUps.name = "Pull-Ups"
        pullUps.primaryMuscle = "Back"

        let archerPushUps = Exercise()
        archerPushUps.name = "Archer Push-Ups"
        archerPushUps.primaryMuscle = "Chest"

        repository.stubbedAllExercises = [pushUps, pullUps, archerPushUps]

        let viewModel = LibraryViewModel(exercises: repository)
        await viewModel.load()

        viewModel.searchText = "push"
        viewModel.selectedFilter = "Chest"
        #expect(viewModel.filteredExercises.map(\.name).sorted() == ["Archer Push-Ups", "Push-Ups"])

        viewModel.searchText = "pull"
        viewModel.selectedFilter = "Chest"
        #expect(viewModel.filteredExercises.isEmpty)

        viewModel.searchText = ""
        viewModel.selectedFilter = "Back"
        #expect(viewModel.filteredExercises.map(\.name) == ["Pull-Ups"])
    }

    @Test
    func loadSetsErrorMessageWhenRepositoryFails() async {
        let repository = MockExerciseRepository()
        repository.shouldThrow = true

        let viewModel = LibraryViewModel(exercises: repository)
        await viewModel.load()

        #expect(viewModel.allExercises.isEmpty)
        #expect(viewModel.errorMessage == "Could not load exercise library.")
        #expect(viewModel.isLoading == false)
    }
}
