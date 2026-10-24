import Testing
@testable import onlybody

@MainActor
struct LibraryViewModelTests {
    @Test func difficultySectionsCombineWithMuscleAndSearchFilters() async {
        let repository = MockExerciseRepository()
        repository.stubbedAllExercises = ["Archer Push-Ups", "Wall Push-Ups", "Standard Push-Ups"].map { name in
            var exercise = ExerciseSnapshot()
            exercise.name = name
            exercise.primaryMuscle = "Chest"
            return exercise
        }
        let viewModel = LibraryViewModel(exercises: repository)
        await viewModel.load()
        #expect(viewModel.sections.map(\.difficulty) == [.beginner, .intermediate, .advanced])
        #expect(viewModel.sections.flatMap(\.exercises).count == 3)
        viewModel.selectedDifficulty = .beginner
        viewModel.selectedFilter = "Chest"
        viewModel.searchText = "wall"
        #expect(viewModel.filteredExercises.map(\.name) == ["Wall Push-Ups"])
        #expect(viewModel.sections.map(\.difficulty) == [.beginner])
        viewModel.selectedFilter = "Back"
        #expect(viewModel.sections.isEmpty)
        viewModel.selectedDifficulty = nil
        viewModel.selectedFilter = "All"
        viewModel.searchText = ""
        #expect(viewModel.sections.count == 3)
    }

    @Test func legacyUnknownExercisesStayVisibleInUnratedSection() async {
        let repository = MockExerciseRepository()
        var exercise = ExerciseSnapshot()
        exercise.name = "Legacy custom movement"
        repository.stubbedAllExercises = [exercise]
        let viewModel = LibraryViewModel(exercises: repository)
        await viewModel.load()
        #expect(viewModel.sections.map(\.difficulty) == [.unrated])
        #expect(viewModel.sections.first?.exercises == [exercise])
    }

    @Test
    func loadPopulatesExercisesAndFiltersBySearchAndMuscle() async {
        let repository = MockExerciseRepository()

        var pushUps = ExerciseSnapshot()
        pushUps.name = "Push-Ups"
        pushUps.primaryMuscle = "Chest"

        var pullUps = ExerciseSnapshot()
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

        var pushUps = ExerciseSnapshot()
        pushUps.name = "Push-Ups"
        pushUps.primaryMuscle = "Chest"

        var pullUps = ExerciseSnapshot()
        pullUps.name = "Pull-Ups"
        pullUps.primaryMuscle = "Back"

        var archerPushUps = ExerciseSnapshot()
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
