import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartReplacementViewModelTests {
    @Test func showingLegacyConflictsNeverBypassesRegionExclusions() throws {
        let exercises = try BundledExerciseCatalog.load(from: #require(Bundle.main.url(forResource: "default", withExtension: "store")))
        let original = try #require(exercises.first { $0.smartMetadata?.role == .main && $0.smartMetadata?.movement == .push })
        let item = WorkoutItemSnapshot(exercise: original)
        let configuration = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], level: .advanced,
            equipmentMode: .standardGym, excludedRegions: [.shoulder])
        let model = SmartReplacementViewModel(item: item, items: [item], configuration: configuration, catalog: exercises)
        model.equipmentUnavailable = false
        #expect(model.alternatives.isEmpty)
        #expect(model.alternatives.isEmpty)
    }

    @Test func conflictsRemainHiddenAndEquipmentReasonNeverBecomesPermanentExclusion() throws {
        let exercises = try BundledExerciseCatalog.load(from: #require(Bundle.main.url(forResource: "default", withExtension: "store")))
        let original = try #require(exercises.first { $0.smartMetadata?.role == .main && $0.smartMetadata?.movement == .push })
        let item = WorkoutItemSnapshot(exercise: original)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], level: .advanced,
            equipmentMode: .standardGym, excludedLoads: Set(ExerciseLoad.allCases))
        let model = SmartReplacementViewModel(item: item, items: [item], configuration: config, catalog: exercises)
        model.equipmentUnavailable = false
        #expect(model.alternatives.allSatisfy { SmartSelectionGenerator().conflicts($0, configuration: config).isEmpty })
        #expect(model.alternatives.allSatisfy { !Set($0.primaryMuscles).isDisjoint(with: original.primaryMuscles) })
        model.equipmentUnavailable = true
        let unavailable = Set(original.equipment.filter { $0 != "None" })
        #expect(model.alternatives.allSatisfy { unavailable.isDisjoint(with: $0.equipment) })
        #expect(config.excludedExercises.isEmpty)
    }
}
