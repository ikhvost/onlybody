import Foundation
import Observation

/// Independent picker state; changing it never alters library filters.
@MainActor @Observable
final class ExercisePickerViewModel {
    var exercises: [ExerciseSnapshot]
    var searchText = ""
    var selectedFilter = "All"
    var selectedEquipment: String?
    var hasActiveFilters: Bool { !searchText.isEmpty || selectedFilter != "All" || selectedEquipment != nil }
    var equipmentOptions: [String] {
        Set(exercises.flatMap { $0.equipment.isEmpty ? ["None"] : $0.equipment })
            .sorted { CatalogLocalization.label($0).localizedStandardCompare(CatalogLocalization.label($1)) == .orderedAscending }
    }
    var filteredExercises: [ExerciseSnapshot] {
        exercises.filter {
            $0.matchesSearch(searchText) && $0.matchesMuscleFilter(selectedFilter)
                && $0.matchesEquipmentFilter(selectedEquipment)
        }.sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }
    init(exercises: [ExerciseSnapshot]) { self.exercises = exercises }
    func clearFilters() { searchText = ""; selectedFilter = "All"; selectedEquipment = nil }
}
