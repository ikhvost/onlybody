import Foundation
import Observation

@MainActor
@Observable
final class LibraryViewModel {
    private let exercisesRepository: any ExerciseRepository

    var allExercises: [Exercise] = []
    var searchText = ""
    var selectedFilter = "All"
    var isLoading = false
    var errorMessage: String? = nil

    let filters = [
        "All",
        "Chest",
        "Back",
        "Shoulders",
        "Arms",
        "Core",
        "Quads",
        "Glutes",
        "Hamstrings",
        "Calves",
        "Full Body"
    ]

    var filteredExercises: [Exercise] {
        allExercises.filter {
            (selectedFilter == "All" || $0.primaryMuscle == selectedFilter) &&
            (searchText.isEmpty || $0.name.localizedStandardContains(searchText))
        }
    }

    init(exercises: any ExerciseRepository) {
        self.exercisesRepository = exercises
    }

    func exercise(id: UUID) -> Exercise? {
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
