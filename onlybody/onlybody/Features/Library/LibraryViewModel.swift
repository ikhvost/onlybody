import Foundation
import Observation

@MainActor
@Observable
final class LibraryViewModel {
    private let exercisesRepository: any ExerciseRepository

    var allExercises: [ExerciseSnapshot] = []
    var searchText = ""
    var selectedFilter = "All"
    var selectedDifficulty: ExerciseDifficulty?
    var isLoading = false
    var errorMessage: String?

    let filters = ExerciseCatalog.filters

    var filteredExercises: [ExerciseSnapshot] {
        allExercises.filter {
            $0.matchesMuscleFilter(selectedFilter) &&
            (selectedDifficulty == nil || $0.difficulty == selectedDifficulty) &&
            (searchText.isEmpty || $0.name.localizedStandardContains(searchText))
        }
    }

    var sections: [LibraryDifficultySection] {
        let filtered = filteredExercises
        return ExerciseDifficulty.allCases.compactMap { level in
            let matches = filtered.filter { $0.difficulty == level }
                .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            return matches.isEmpty ? nil : LibraryDifficultySection(difficulty: level, exercises: matches)
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
