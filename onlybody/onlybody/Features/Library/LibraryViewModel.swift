import Foundation
import Observation

@MainActor
@Observable
final class LibraryViewModel {
    private let exercisesRepository: any ExerciseRepository

    var allExercises: [ExerciseSnapshot] = []
    var searchText = ""
    var selectedFilter = "All"
    var isLoading = false
    var errorMessage: String?

    let filters = ExerciseCatalog.filters

    var filteredExercises: [ExerciseSnapshot] {
        allExercises.filter {
            (selectedFilter == "All" || $0.primaryMuscle == selectedFilter) &&
            (searchText.isEmpty || $0.name.localizedStandardContains(searchText))
        }
    }

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
            errorMessage = "Could not load exercise library."
        }
    }
}
