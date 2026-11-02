import Foundation
import SwiftData
import Testing
@testable import onlybody

@MainActor
struct BundledExerciseCatalogTests {
    @Test func catalogReadsSeedWithoutChangingItsBytesOrRequiringBundledSidecars() throws {
        let seed = try #require(Bundle.main.url(forResource: "default", withExtension: "store"))
        let original = try Data(contentsOf: seed)
        let catalog = try BundledExerciseCatalog.load(from: seed)
        #expect(catalog.count == 65)
        #expect(try Data(contentsOf: seed) == original)
        #expect(Set(catalog.map(\.name)) == Set(ExerciseDifficultyCatalog.levels.keys))
    }

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
        #expect(exercises.count == 65)
        #expect(Set(exercises.map(\.id)).count == exercises.count)
        #expect(Set(exercises.map(\.name)).count == exercises.count)
        #expect(Set(exercises.map(\.name)) == Set(ExerciseDemonstrationCatalog.all.map(\.exerciseName)))
        #expect(try context.fetchCount(FetchDescriptor<Workout>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<WorkoutItem>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Session>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<SessionItem>()) == 0)

        for exercise in exercises {
            let diagram = MovementDetailViewModel(exercise: exercise).muscleDiagram
            #expect(exercise.difficulty != .unrated)
            #expect(diagram.hasHighlightedRegions)
            #expect(!diagram.primary.isEmpty)
            #expect(Set(diagram.primary.map(\.rawValue)) == Set(exercise.primaryMuscles))
            #expect(Set(diagram.secondary.map(\.rawValue)) == Set(exercise.secondaryMuscles))
            #expect(ExerciseCatalog.primaryMuscles.contains(exercise.primaryMuscle))
            #expect(Set(exercise.secondaryMuscles).isSubset(of: Set(ExerciseCatalog.allMuscles)))
            #expect(!exercise.secondaryMuscles.contains(exercise.primaryMuscle))
            #expect(!exercise.equipment.isEmpty)
            #expect(Set(exercise.equipment).isSubset(of: Set(ExerciseCatalog.equipment)))
            #expect(!exercise.equipment.contains("None") || exercise.equipment == ["None"])
            #expect(ExerciseFrequency(rawValue: exercise.frequencyPreference) != nil)
        }

        #expect(Set(ExerciseDifficultyCatalog.levels.keys) == Set(exercises.map(\.name)))

        for muscle in ExerciseCatalog.primaryMuscles {
            viewModel.selectedFilter = muscle
            let expected = exercises.filter {
                $0.primaryMuscles.contains(muscle) || (muscle == "Full Body" && $0.muscleProfile.isFullBody)
            }
            #expect(Set(viewModel.filteredExercises.map(\.id)) == Set(expected.map(\.id)))
        }

        viewModel.selectedFilter = "Back"
        #expect(viewModel.filteredExercises.count == 11)
        #expect(viewModel.filteredExercises.filter { $0.equipment == ["None"] }.count == 4)
        viewModel.searchText = "snow"
        #expect(viewModel.filteredExercises.map(\.name) == ["Reverse Snow Angels"])
        viewModel.searchText = ""
        viewModel.selectedFilter = "Core"
        #expect(viewModel.filteredExercises.count == 11)
        viewModel.selectedFilter = "All"
        #expect(viewModel.filteredExercises.count == 65)
    }
}
