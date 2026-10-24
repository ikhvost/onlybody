import Foundation
import SwiftData
import Testing
@testable import onlybody

@MainActor
struct BundledExerciseCatalogTests {
    @Test func freshInstallationLoadsCuratedCatalogIntoLibrary() async throws {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let seed = try #require(Bundle.main.url(forResource: "default", withExtension: "store"))
        let url = directory.appending(path: "default.store")
        try FileManager.default.copyItem(at: seed, to: url)
        let container = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(url: url)
        )
        let context = ModelContext(container)
        let repository = SwiftDataExerciseRepository(context: context)
        let viewModel = LibraryViewModel(exercises: repository)
        await viewModel.load()

        #expect(viewModel.errorMessage == nil)
        let exercises = viewModel.allExercises
        #expect(exercises.count == 49)
        #expect(Set(exercises.map(\.id)).count == exercises.count)
        #expect(Set(exercises.map(\.name)).count == exercises.count)
        #expect(Set(exercises.map(\.name)) == Set(ExerciseDemonstrationCatalog.all.map(\.exerciseName)))
        #expect(try context.fetchCount(FetchDescriptor<Workout>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<WorkoutItem>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Session>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<SessionItem>()) == 0)

        for exercise in exercises {
            let diagram = MuscleDiagram(primaryMuscle: exercise.primaryMuscle, secondaryMuscles: exercise.secondaryMuscles)
            #expect(diagram.hasHighlightedRegions)
            #expect(exercise.primaryMuscle == "Full Body" || !diagram.primary.isEmpty)
            #expect(Set(diagram.secondary.map(\.rawValue)) == Set(exercise.secondaryMuscles))
            #expect(ExerciseCatalog.primaryMuscles.contains(exercise.primaryMuscle))
            #expect(Set(exercise.secondaryMuscles).isSubset(of: Set(ExerciseCatalog.allMuscles)))
            #expect(!exercise.secondaryMuscles.contains(exercise.primaryMuscle))
            #expect(!exercise.equipment.isEmpty)
            #expect(Set(exercise.equipment).isSubset(of: Set(ExerciseCatalog.equipment)))
            #expect(!exercise.equipment.contains("None") || exercise.equipment == ["None"])
            #expect(ExerciseFrequency(rawValue: exercise.frequencyPreference) != nil)
        }

        for muscle in ExerciseCatalog.primaryMuscles {
            viewModel.selectedFilter = muscle
            #expect(!viewModel.filteredExercises.isEmpty)
            #expect(viewModel.filteredExercises.allSatisfy { $0.primaryMuscle == muscle })
        }

        viewModel.selectedFilter = "Back"
        #expect(viewModel.filteredExercises.count == 9)
        #expect(viewModel.filteredExercises.filter { $0.equipment == ["None"] }.count == 3)
        viewModel.searchText = "snow"
        #expect(viewModel.filteredExercises.map(\.name) == ["Reverse Snow Angels"])
        viewModel.searchText = ""
        viewModel.selectedFilter = "Core"
        #expect(viewModel.filteredExercises.count == 5)
        viewModel.selectedFilter = "All"
        #expect(viewModel.filteredExercises.count == 49)
    }
}
