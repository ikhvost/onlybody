import SwiftUI
import Testing
@testable import onlybody

@MainActor
struct ExerciseMuscleCatalogTests {
    @Test func everyReleasedExerciseHasValidDisjointRolesAndDrawableRegions() {
        #expect(Set(ExerciseMuscleCatalog.profiles.keys) == Set(ExerciseDifficultyCatalog.levels.keys))
        #expect(ExerciseMuscleCatalog.profiles.count == 65)
        let allowed = Set(MuscleGroup.allCases.map(\.rawValue))
        for profile in ExerciseMuscleCatalog.profiles.values {
            #expect(!profile.primary.isEmpty)
            #expect(Set(profile.primary).isDisjoint(with: profile.secondary))
            #expect(Set(profile.primary + profile.secondary).isSubset(of: allowed))
        }
        for group in MuscleGroup.allCases {
            #expect(!MuscleRegionPaths.path(for: group).isEmpty)
        }
        #expect(MuscleRegionPaths.path(for: .biceps) != MuscleRegionPaths.path(for: .triceps))
    }

    @Test func legacyDipsKeepIdentityButResolveBothPrimeMovers() {
        let exercise = ExerciseSnapshot(name: "Dips", primaryMuscle: "Arms", secondaryMuscles: ["Chest", "Shoulders"])
        let original = exercise
        #expect(exercise.primaryMuscles == ["Chest", "Triceps"])
        #expect(exercise.supportingMuscles == ["Shoulders"])
        #expect(exercise == original)
        let diagram = MovementDetailViewModel(exercise: exercise).muscleDiagram
        #expect(Set(diagram.primary) == [.chest, .triceps])
        #expect(diagram.secondary == [.shoulders])
    }

    @Test func libraryFiltersAnyPrimaryAndSeparatesArmMuscles() async {
        let repository = MockExerciseRepository()
        repository.stubbedAllExercises = ["Dips", "Chin-Ups", "Burpees"].map { ExerciseSnapshot(name: $0) }
        let model = LibraryViewModel(exercises: repository)
        await model.load()
        model.selectedFilter = "Triceps"
        #expect(Set(model.filteredExercises.map(\.name)) == ["Dips", "Burpees"])
        model.selectedFilter = "Biceps"
        #expect(model.filteredExercises.map(\.name) == ["Chin-Ups"])
        model.selectedFilter = "Full Body"
        #expect(model.filteredExercises.map(\.name) == ["Burpees"])
    }

    @Test func multiplePrimariesWinOverSecondaryAndLegacyUnknownsRemainUsable() {
        let diagram = MuscleDiagram(primaryMuscles: ["Chest", "Triceps", "Chest"], secondaryMuscles: ["Triceps", "Shoulders"])
        #expect(Set(diagram.primary) == [.chest, .triceps])
        #expect(diagram.secondary == [.shoulders])
        let legacy = ExerciseSnapshot(name: "Custom", primaryMuscle: "Arms")
        #expect(legacy.primaryMuscles == ["Biceps", "Triceps", "Forearms"])
        #expect(legacy.primaryMuscle == "Arms")
    }

    @Test func generatorUsesNewRolesAndUnderstandsSavedArmsTarget() {
        let exercises = ["Dips", "Chin-Ups", "Standard Push-Ups"].map { ExerciseSnapshot(name: $0, equipment: ["None"]) }
        let generator = SmartWorkoutGenerator(randomSets: { _ in 3 }, randomReps: { _ in 10 }, randomRest: { _ in 30 })
        let triceps = generator.generate(config: SmartWorkoutConfiguration(targetMuscleGroups: ["Triceps"], durationMinutes: 60), from: exercises)
        #expect(Set(triceps.map(\.exercise.name)) == ["Dips", "Standard Push-Ups"])
        let legacy = generator.generate(config: SmartWorkoutConfiguration(targetMuscleGroups: ["Arms"], durationMinutes: 60), from: exercises)
        #expect(legacy.count == 3)
    }
}
