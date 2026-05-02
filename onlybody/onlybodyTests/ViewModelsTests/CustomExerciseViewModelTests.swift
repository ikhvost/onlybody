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

    @Test
    func saveFailsWhenNameIsBlank() async {
        let repository = MockExerciseRepository()
        let viewModel = CustomExerciseViewModel(exercises: repository)

        viewModel.name = "   "
        viewModel.togglePrimaryMuscle("Core")

        let didSave = await viewModel.save()

        #expect(!didSave)
        #expect(repository.savedExercises.isEmpty)
    }

    @Test
    func saveFailsWhenPrimaryMuscleNotSelected() async {
        let repository = MockExerciseRepository()
        let viewModel = CustomExerciseViewModel(exercises: repository)

        viewModel.name = "Pike Push-Ups"

        let didSave = await viewModel.save()

        #expect(!didSave)
        #expect(repository.savedExercises.isEmpty)
    }

    @Test
    func saveWithSelectedEquipment() async {
        let repository = MockExerciseRepository()
        let viewModel = CustomExerciseViewModel(exercises: repository)

        viewModel.name = "Weighted Dips"
        viewModel.togglePrimaryMuscle("Chest")
        viewModel.toggleEquipment("Dumbbells")
        viewModel.toggleEquipment("Pull-up Bar")

        let didSave = await viewModel.save()

        #expect(didSave)
        #expect(repository.savedExercises.count == 1)
        #expect(repository.savedExercises.first?.name == "Weighted Dips")
        #expect(repository.savedExercises.first?.equipment == ["Dumbbells", "Pull-up Bar"])
    }

    @Test
    func saveSurfacesRepositoryError() async {
        let repository = MockExerciseRepository()
        repository.shouldThrow = true
        let viewModel = CustomExerciseViewModel(exercises: repository)

        viewModel.name = "Test Exercise"
        viewModel.togglePrimaryMuscle("Arms")

        let didSave = await viewModel.save()

        #expect(!didSave)
        #expect(viewModel.errorMessage != nil)
        #expect(repository.savedExercises.isEmpty)
    }

    @Test
    func togglePrimaryMuscleRemovesFromSecondary() {
        let repository = MockExerciseRepository()
        let viewModel = CustomExerciseViewModel(exercises: repository)

        viewModel.toggleSecondaryMuscle("Core")
        #expect(viewModel.secondaryMuscles.contains("Core"))

        viewModel.togglePrimaryMuscle("Core")
        #expect(viewModel.primaryMuscle == "Core")
        #expect(!viewModel.secondaryMuscles.contains("Core"))
    }

    @Test
    func toggleEquipmentNoneClearsOtherEquipment() {
        let repository = MockExerciseRepository()
        let viewModel = CustomExerciseViewModel(exercises: repository)

        viewModel.toggleEquipment("Dumbbells")
        viewModel.toggleEquipment("Barbell")
        #expect(viewModel.selectedEquipment.contains("Dumbbells"))
        #expect(viewModel.selectedEquipment.contains("Barbell"))

        viewModel.toggleEquipment("None")
        #expect(viewModel.selectedEquipment == ["None"])

        viewModel.toggleEquipment("None")
        #expect(viewModel.selectedEquipment.isEmpty)
    }

    @Test
    func toggleEquipmentClearsNoneWhenAddingOther() {
        let repository = MockExerciseRepository()
        let viewModel = CustomExerciseViewModel(exercises: repository)

        viewModel.toggleEquipment("None")
        #expect(viewModel.selectedEquipment == ["None"])

        viewModel.toggleEquipment("Kettlebell")
        #expect(viewModel.selectedEquipment == ["Kettlebell"])
        #expect(!viewModel.selectedEquipment.contains("None"))
    }

    @Test
    func isValidReflectsNameAndPrimaryMuscle() {
        let repository = MockExerciseRepository()
        let viewModel = CustomExerciseViewModel(exercises: repository)

        #expect(!viewModel.isValid)

        viewModel.name = "L-Sit"
        #expect(!viewModel.isValid)

        viewModel.togglePrimaryMuscle("Core")
        #expect(viewModel.isValid)

        viewModel.name = ""
        #expect(!viewModel.isValid)
    }

    @Test
    func toggleSecondaryMuscleTogglesCorrectly() {
        let repository = MockExerciseRepository()
        let viewModel = CustomExerciseViewModel(exercises: repository)

        viewModel.toggleSecondaryMuscle("Glutes")
        #expect(viewModel.secondaryMuscles.contains("Glutes"))

        viewModel.toggleSecondaryMuscle("Glutes")
        #expect(!viewModel.secondaryMuscles.contains("Glutes"))
    }
}
