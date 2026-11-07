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
        model.showsConflicts = true
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
        #expect(model.alternatives.allSatisfy { model.conflicts($0).isEmpty })
        model.showsConflicts = true
        #expect(model.alternatives.allSatisfy { $0.smartMetadata?.role == original.smartMetadata?.role })
        model.equipmentUnavailable = true
        let unavailable = Set(original.equipment.filter { $0 != "None" })
        #expect(model.alternatives.allSatisfy { unavailable.isDisjoint(with: $0.equipment) })
        #expect(config.excludedExercises.isEmpty)
    }
}
