import Foundation
import Observation

/// Independent picker state; changing it never alters library filters.
@MainActor @Observable
final class ExercisePickerViewModel {
    let exercises: [ExerciseSnapshot]
    var searchText = ""
    var selectedFilter = "All"
    var selectedDifficulty: ExerciseDifficulty?
    var filteredExercises: [ExerciseSnapshot] {
        exercises.filter {
            $0.matchesSearch(searchText) && $0.matchesMuscleFilter(selectedFilter)
                && (selectedDifficulty == nil || $0.difficulty == selectedDifficulty)
        }.sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }
    init(exercises: [ExerciseSnapshot]) { self.exercises = exercises }
    func clearFilters() { searchText = ""; selectedFilter = "All"; selectedDifficulty = nil }
}
