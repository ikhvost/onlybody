import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct LibraryViewModelTests {
    @Test func equipmentCombinesWithMuscleAndSearchFilters() async {
        let repository = MockExerciseRepository()
        repository.stubbedAllExercises = [
            ExerciseSnapshot(name: "Fixture press", primaryMuscle: "Chest", equipment: ["Dumbbells"]),
            ExerciseSnapshot(name: "Fixture push-up", primaryMuscle: "Chest", equipment: ["None"]),
            ExerciseSnapshot(name: "Fixture row", primaryMuscle: "Back", equipment: ["Dumbbells"])
        ]
        let model = LibraryViewModel(exercises: repository)
        await model.load()
        model.selectedEquipment = "Dumbbells"
        model.selectedFilter = "Chest"
        model.searchText = "press"
        #expect(model.filteredExercises.map(\.name) == ["Fixture press"])
        model.selectedFilter = "Core"
        #expect(model.filteredExercises.isEmpty)
        model.clearFilters()
        #expect(model.displayedExercises.count == 3)
        #expect(Set(model.equipmentOptions) == ["None", "Dumbbells"])
    }

    @Test func unknownExercisesWithoutEquipmentStayVisible() async {
        let repository = MockExerciseRepository()
        let exercise = ExerciseSnapshot(name: "Legacy custom movement")
        repository.stubbedAllExercises = [exercise]
        let model = LibraryViewModel(exercises: repository)
        await model.load()
        model.selectedEquipment = "None"
        #expect(model.filteredExercises == [exercise])
    }

    @Test
    func loadPopulatesExercisesAndFiltersBySearchAndMuscle() async {
        let repository = MockExerciseRepository()

        var pushUps = ExerciseSnapshot()
        pushUps.name = "Fixture push-up"
        pushUps.primaryMuscle = "Chest"

        var pullUps = ExerciseSnapshot()
        pullUps.name = "Fixture pull-up"
        pullUps.primaryMuscle = "Back"

        repository.stubbedAllExercises = [pushUps, pullUps]

        let viewModel = LibraryViewModel(exercises: repository)
        await viewModel.load()

        #expect(viewModel.allExercises.count == 2)
        #expect(viewModel.errorMessage == nil)

        viewModel.searchText = "push"
        #expect(viewModel.filteredExercises.map(\.name) == ["Fixture push-up"])

        viewModel.searchText = ""
        viewModel.selectedFilter = "Back"
        #expect(viewModel.filteredExercises.map(\.name) == ["Fixture pull-up"])
    }

    @Test
    func filtersBySearchAndMuscleCombined() async {
        let repository = MockExerciseRepository()

        var pushUps = ExerciseSnapshot()
        pushUps.name = "Fixture push-up"
        pushUps.primaryMuscle = "Chest"

        var pullUps = ExerciseSnapshot()
        pullUps.name = "Fixture pull-up"
        pullUps.primaryMuscle = "Back"

        var archerPushUps = ExerciseSnapshot()
        archerPushUps.name = "Fixture archer push-up"
        archerPushUps.primaryMuscle = "Chest"

        repository.stubbedAllExercises = [pushUps, pullUps, archerPushUps]

        let viewModel = LibraryViewModel(exercises: repository)
        await viewModel.load()

        viewModel.searchText = "push"
        viewModel.selectedFilter = "Chest"
        #expect(viewModel.filteredExercises.map(\.name).sorted() == ["Fixture archer push-up", "Fixture push-up"])

        viewModel.searchText = "pull"
        viewModel.selectedFilter = "Chest"
        #expect(viewModel.filteredExercises.isEmpty)

        viewModel.searchText = ""
        viewModel.selectedFilter = "Back"
        #expect(viewModel.filteredExercises.map(\.name) == ["Fixture pull-up"])
    }

    @Test
    func loadSetsErrorMessageWhenRepositoryFails() async {
        let repository = MockExerciseRepository()
        repository.shouldThrow = true

        let viewModel = LibraryViewModel(exercises: repository)
        await viewModel.load()

        #expect(viewModel.allExercises.isEmpty)
        #expect(viewModel.errorMessage == String(localized: .uiCouldNotLoadExerciseLibrary))
        #expect(viewModel.isLoading == false)
    }
}
