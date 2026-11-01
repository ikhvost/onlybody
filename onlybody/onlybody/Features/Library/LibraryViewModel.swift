import Foundation
import Observation

@MainActor
@Observable
final class LibraryViewModel {
    private let exercisesRepository: any ExerciseRepository

    var allExercises: [ExerciseSnapshot] = []
    var searchText = ""
    var selectedFilter = "All"
    var selectedEquipment: String?
    var equipmentOptions: [String] {
        Set(allExercises.flatMap { $0.equipment.isEmpty ? ["None"] : $0.equipment })
            .sorted { CatalogLocalization.label($0).localizedStandardCompare(CatalogLocalization.label($1)) == .orderedAscending }
    }
    var isLoading = false
    var errorMessage: String?

    let filters = ExerciseCatalog.filters

    var filteredExercises: [ExerciseSnapshot] {
        allExercises.filter {
            $0.matchesMuscleFilter(selectedFilter) &&
            $0.matchesEquipmentFilter(selectedEquipment) &&
            $0.matchesSearch(searchText)
        }
    }

    var displayedExercises: [ExerciseSnapshot] {
        filteredExercises.sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
    }

    func clearFilters() { selectedFilter = "All"; selectedEquipment = nil; searchText = "" }

    init(exercises: any ExerciseRepository) {
        self.exercisesRepository = exercises
    }

    func exercise(id: UUID) -> ExerciseSnapshot? {
        allExercises.first { $0.id == id }
    }

    func load() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            allExercises = try await exercisesRepository.allExercises()
        } catch {
            errorMessage = String(localized: .uiCouldNotLoadExerciseLibrary)
        }
    }
}
