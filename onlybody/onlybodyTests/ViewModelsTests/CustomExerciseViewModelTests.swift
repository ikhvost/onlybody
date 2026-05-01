import Testing
@testable import onlybody

@MainActor
struct CustomExerciseViewModelTests {
    @Test
    func saveBuildsCustomExerciseWithTrimmedNameAndDefaultEquipment() async {
        let repository = MockExerciseRepository()
        let viewModel = CustomExerciseViewModel(exercises: repository)

        viewModel.name = "  Archer Push-Ups  "
        viewModel.togglePrimaryMuscle("Chest")
        viewModel.toggleSecondaryMuscle("Shoulders")

        let didSave = await viewModel.save()

        #expect(didSave)
        #expect(repository.savedExercises.count == 1)
        #expect(repository.savedExercises.first?.name == "Archer Push-Ups")
        #expect(repository.savedExercises.first?.primaryMuscle == "Chest")
        #expect(repository.savedExercises.first?.secondaryMuscles == ["Shoulders"])
        #expect(repository.savedExercises.first?.equipment == ["None"])
        #expect(repository.savedExercises.first?.isCustom == true)
    }
}
