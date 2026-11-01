import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct ExercisePickerViewModelTests {
    @Test func equipmentFilterCombinesWithSearchAndMuscleAndResets() {
        let model = ExercisePickerViewModel(exercises: [
            ExerciseSnapshot(name: "Fixture dumbbell press", primaryMuscle: "Chest", equipment: ["Dumbbells", "Bench"]),
            ExerciseSnapshot(name: "Fixture barbell press", primaryMuscle: "Chest", equipment: ["Barbell", "Bench"]),
            ExerciseSnapshot(name: "Fixture row", primaryMuscle: "Back", equipment: ["Dumbbells"])
        ])
        model.selectedFilter = "Chest"
        model.selectedEquipment = "Dumbbells"
        model.searchText = "press"
        #expect(model.filteredExercises.map(\.name) == ["Fixture dumbbell press"])
        model.selectedEquipment = "Bench"
        #expect(model.filteredExercises.count == 2)
        model.clearFilters()
        #expect(model.filteredExercises.count == 3)
        #expect(model.selectedEquipment == nil)
        #expect(Set(model.equipmentOptions) == ["Dumbbells", "Barbell", "Bench"])
    }

    @Test func filtersAreIndependentAndCanBeReset() {
        let exercises = [ExerciseSnapshot(name: "Fixture chest", primaryMuscle: "Chest"),
                         ExerciseSnapshot(name: "Fixture core", primaryMuscle: "Core")]
        let first = ExercisePickerViewModel(exercises: exercises)
        let second = ExercisePickerViewModel(exercises: exercises)
        first.selectedFilter = "Chest"
        #expect(first.filteredExercises.count == 1)
        #expect(second.filteredExercises.count == 2)
        first.searchText = "missing"
        #expect(first.filteredExercises.isEmpty)
        first.clearFilters()
        #expect(first.filteredExercises.count == 2)
    }
}
