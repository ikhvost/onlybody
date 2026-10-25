import Foundation
import SwiftData
import Testing
@testable import onlyweights

@MainActor
struct GymCatalogTests {
    @Test func bundledCatalogIsCompleteAndDoesNotMutateSeed() throws {
        let seed = try #require(Bundle.main.url(forResource: "default", withExtension: "store"))
        let original = try Data(contentsOf: seed)
        let exercises = try BundledExerciseCatalog.load(from: seed)
        #expect(exercises.count == 60)
        #expect(Set(exercises.map(\.id)).count == 60)
        #expect(Set(exercises.map(\.name)).count == 60)
        #expect(try Data(contentsOf: seed) == original)
        #expect(Set(exercises.map(\.name)) == Set(ExerciseDifficultyCatalog.levels.keys))
        #expect(Set(exercises.map(\.name)) == Set(ExerciseMuscleCatalog.profiles.keys))
        #expect(!exercises.contains { $0.name == "Standard Push-Ups" })
        for exercise in exercises {
            #expect(exercise.difficulty != .unrated)
            #expect(!exercise.equipment.isEmpty)
            #expect(Set(exercise.equipment).isSubset(of: Set(ExerciseCatalog.equipment)))
            #expect(!exercise.primaryMuscles.isEmpty)
            #expect(Set(exercise.primaryMuscles).isDisjoint(with: exercise.supportingMuscles))
            let diagram = MovementDetailViewModel(exercise: exercise).muscleDiagram
            #expect(diagram.hasHighlightedRegions)
            #expect(Set(diagram.primary.map(\.rawValue)) == Set(exercise.primaryMuscles))
            #expect(Set(diagram.secondary.map(\.rawValue)) == Set(exercise.supportingMuscles))
        }
    }

    @Test func freshInstallLoadsGymLibraryAndSavesWorkoutsAcrossReopen() async throws {
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
        let catalog = try BundledExerciseCatalog.load(from: seed)
        let library = LibraryViewModel(exercises: SwiftDataExerciseRepository(context: context, catalog: catalog))
        await library.load()
        #expect(library.errorMessage == nil)
        #expect(library.allExercises.count == 60)
        #expect(try context.fetchCount(FetchDescriptor<Workout>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Session>()) == 0)
        library.selectedFilter = "Quads"
        #expect(Set(library.filteredExercises.map(\.name)) == [
            "Barbell Back Squat", "Leg Press", "Leg Extension", "Barbell Front Squat", "Sumo Barbell Deadlift",
            "Dumbbell Goblet Squat", "Dumbbell Bulgarian Split Squat", "Dumbbell Reverse Lunge",
            "Dumbbell Walking Lunge", "Dumbbell Step-Up", "Hack Squat"
        ])
        library.searchText = "extension"
        #expect(library.filteredExercises.map(\.name) == ["Leg Extension"])
        library.selectedFilter = "Back"
        library.selectedDifficulty = .advanced
        library.searchText = "wEiGhTeD"
        #expect(Set(library.filteredExercises.map(\.name)) == ["Weighted Pull-Ups", "Weighted Chin-Ups"])
        let exercise = try #require(catalog.first { $0.name == "Weighted Dips" })
        let workout = WorkoutSnapshot(name: "Gym routine", items: [WorkoutItemSnapshot(exercise: exercise)])
        let workouts = SwiftDataWorkoutRepository(context: ModelContext(container), catalog: catalog)
        try await workouts.save(workout)
        let reopened = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(url: url)
        )
        let repository = SwiftDataWorkoutRepository(context: ModelContext(reopened), catalog: catalog)
        #expect(try await repository.workout(by: workout.id)?.items.first?.exercise?.id == exercise.id)
    }

    @Test func movementWithoutVideoNeverStartsLoading() async throws {
        let exercise = ExerciseSnapshot(name: "Custom gym movement without demonstration", primaryMuscle: "Chest")
        let composition = AppComposition(
            configuration: .onlyWeights, exercises: MockExerciseRepository(),
            workouts: MockWorkoutRepository(), sessions: MockSessionRepository(), preferences: WorkoutPreferences(),
            reminders: WorkoutReminderCoordinator(
                preferences: WorkoutPreferences(), workouts: MockWorkoutRepository(), notifications: MockWorkoutNotificationClient()
            )
        )
        let model = composition.movement(exercise)
        model.loadDemonstration()
        #expect(model.demonstration == nil)
        #expect(model.demonstrationState == .idle)
    }

    @Test func releaseVideosCoverCatalogAndReachMovementDetails() throws {
        let seed = try #require(Bundle.main.url(forResource: "default", withExtension: "store"))
        let exercises = try BundledExerciseCatalog.load(from: seed)
        let demonstrations = ExerciseDemonstrationCatalog.all
        #expect(demonstrations.count == 60)
        #expect(Set(demonstrations.map(\.id)).count == 60)
        #expect(Set(demonstrations.map(\.exerciseName)) == Set(exercises.map(\.name)))
        #expect(demonstrations.allSatisfy { $0.isValid })
        let composition = AppComposition(
            configuration: .onlyWeights, exercises: MockExerciseRepository(),
            workouts: MockWorkoutRepository(), sessions: MockSessionRepository(), preferences: WorkoutPreferences(),
            reminders: WorkoutReminderCoordinator(
                preferences: WorkoutPreferences(), workouts: MockWorkoutRepository(), notifications: MockWorkoutNotificationClient()
            )
        )
        for exercise in exercises {
            let model = composition.movement(exercise)
            #expect(model.demonstration?.exerciseName == exercise.name)
            #expect(model.playerDocument?.baseURL.absoluteString == "https://ikhvost.onlyweights")
        }
    }
}
