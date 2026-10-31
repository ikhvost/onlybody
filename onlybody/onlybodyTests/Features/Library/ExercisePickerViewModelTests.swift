import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct ExercisePickerViewModelTests {
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
