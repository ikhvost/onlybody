import Testing
import UIKit
@testable import onlybody

@MainActor
struct MuscleDiagramTests {
    @Test func referenceImageShipsAtTheCoordinateMapsResolution() throws {
        let image = try #require(UIImage(named: "MuscleAnatomy"))
        let pixels = try #require(image.cgImage)
        #expect(pixels.width == Int(MuscleRegionPaths.viewport))
        #expect(pixels.height == Int(MuscleRegionPaths.viewport))
    }

    @Test func supportsEveryNamedCatalogRegion() {
        #expect(Set(MuscleGroup.allCases.map(\.rawValue)) == Set(ExerciseCatalog.allMuscles))
        for group in MuscleGroup.allCases {
            let diagram = MuscleDiagram(primaryMuscle: group.rawValue, secondaryMuscles: [])
            #expect(diagram.primary == [group])
            #expect(diagram.secondary.isEmpty)
            #expect(diagram.hasHighlightedRegions)
        }
    }

    @Test func primaryWinsAndSecondaryGroupsAreUnique() {
        let diagram = MuscleDiagram(primaryMuscle: "Chest", secondaryMuscles: ["Triceps", "Chest", "Triceps", "Shoulders", "Unknown"])
        #expect(diagram.primary == [.chest])
        #expect(Set(diagram.secondary) == [.triceps, .shoulders])
        #expect(diagram.secondary.count == 2)
    }

    @Test func wholeBodyDoesNotInventIndividualPrimeMovers() {
        let diagram = MuscleDiagram(primaryMuscle: "Full Body", secondaryMuscles: ["Calves", "Shoulders"])
        #expect(diagram.isFullBody)
        #expect(diagram.primary.isEmpty)
        #expect(Set(diagram.secondary) == [.calves, .shoulders])
    }

    @Test func unknownLabelsDoNotHighlightUnrelatedMuscles() {
        let diagram = MuscleDiagram(primaryMuscle: "New region", secondaryMuscles: ["Unknown"])
        #expect(!diagram.hasHighlightedRegions)
        #expect(!diagram.isFullBody)
    }

    @Test func viewModelUsesCurrentExerciseAndProvidesNonColorDescription() {
        var exercise = ExerciseSnapshot()
        exercise.primaryMuscle = "Quads"
        exercise.secondaryMuscles = ["Glutes"]
        let viewModel = MovementDetailViewModel(exercise: exercise)
        #expect(viewModel.muscleDiagram.primary == [.quads])
        #expect(viewModel.muscleDiagram.secondary == [.glutes])
        #expect(viewModel.muscleDiagramDescription.contains("Primary: Quads"))
        #expect(viewModel.muscleDiagramDescription.contains("Secondary: Glutes"))
        viewModel.exercise.primaryMuscle = "Back"
        #expect(viewModel.muscleDiagram.primary == [.back])
    }
}
