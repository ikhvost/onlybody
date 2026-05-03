import Foundation
import Testing
@testable import onlybody

@MainActor
struct MusclePickerViewModelTests {

    @Test
    func initialSelectionIsEmpty() async {
        let viewModel = MusclePickerViewModel()

        #expect(viewModel.selectedMuscles.isEmpty)
        #expect(viewModel.selectionSummary.isEmpty)
    }

    @Test
    func canBuildIsFalseWhenNoSelection() async {
        let viewModel = MusclePickerViewModel()

        #expect(viewModel.canBuild == false)
    }

    @Test
    func canBuildIsTrueWhenAtLeastOneSelected() async {
        let viewModel = MusclePickerViewModel()

        viewModel.toggle("Chest")

        #expect(viewModel.canBuild == true)
    }

    @Test
    func toggleAddsToSelection() async {
        let viewModel = MusclePickerViewModel()

        viewModel.toggle("Chest")

        #expect(viewModel.selectedMuscles == ["Chest"])
    }

    @Test
    func toggleRemovesFromSelection() async {
        let viewModel = MusclePickerViewModel()

        viewModel.toggle("Chest")
        viewModel.toggle("Chest")

        #expect(viewModel.selectedMuscles.isEmpty)
    }

    @Test
    func selectionSummaryJoinsWithPlus() async {
        let viewModel = MusclePickerViewModel()

        viewModel.toggle("Chest")
        viewModel.toggle("Back")

        #expect(viewModel.selectionSummary == "Chest + Back")
    }

    @Test
    func selectionSummaryUsesLabelsNotIDs() async {
        let viewModel = MusclePickerViewModel()

        viewModel.toggle("Full Body")

        #expect(viewModel.selectionSummary == "Full Body")
    }

    @Test
    func allTwelveMusclesPresent() async {
        let viewModel = MusclePickerViewModel()

        #expect(viewModel.muscles.count == 12)

        let expectedLabels = [
            "Chest", "Back", "Shoulders", "Arms",
            "Core", "Quads", "Glutes", "Hamstrings",
            "Calves", "Full Body", "Upper", "Lower"
        ]
        #expect(viewModel.muscles == expectedLabels)
    }

    @Test
    func toggleMultipleMuscles() async {
        let viewModel = MusclePickerViewModel()

        viewModel.toggle("Chest")
        viewModel.toggle("Back")
        viewModel.toggle("Shoulders")

        #expect(viewModel.selectedMuscles.count == 3)
        #expect(viewModel.selectionSummary == "Chest + Back + Shoulders")
    }

    @Test
    func canBuildReturnsToFalseAfterDeselectingAll() async {
        let viewModel = MusclePickerViewModel()

        viewModel.toggle("Chest")
        #expect(viewModel.canBuild == true)

        viewModel.toggle("Chest")
        #expect(viewModel.canBuild == false)
    }
}
