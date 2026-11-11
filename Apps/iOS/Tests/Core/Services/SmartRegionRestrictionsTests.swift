import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartRegionRestrictionsTests {
    @Test func regionExclusionsNeverInventMissingEquipmentToFillTheWorkout() throws {
        let exercises = try BundledExerciseCatalog.load(from: #require(Bundle.main.url(forResource: "default", withExtension: "store")))
        let configuration = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], excludedRegions: [.knee, .hip])
        let plan = SmartSelectionGenerator().plan(configuration: configuration, from: exercises)
        #expect(plan.movements.allSatisfy { $0.exercise.equipment.allSatisfy { $0 == "None" } })
        #expect(plan.movements.allSatisfy {
            SmartRegionRestrictions.allows($0.exercise.name, excluding: configuration.excludedRegions)
        })
    }

    @Test func everySmartProfileHasExplicitRegionReview() throws {
        #expect(Set(SmartRegionRestrictions.regionsByExercise.keys) == Set(SmartExerciseProfiles.entries.keys))
        let exercises = try BundledExerciseCatalog.load(from: #require(Bundle.main.url(forResource: "default", withExtension: "store")))
        for exercise in exercises where exercise.smartMetadata != nil {
            #expect(SmartRegionRestrictions.regionsByExercise[exercise.name] != nil)
        }
        #expect(!SmartRegionRestrictions.allows("Unreviewed exercise", excluding: [.knee]))
    }

    @Test func mechanicalRulesDistinguishSupportedAndUnsupportedVariants() {
        #expect(!SmartRegionRestrictions.allows("Squats", excluding: [.knee]))
        #expect(!SmartRegionRestrictions.allows("Knee Push-Ups", excluding: [.knee]))
        #expect(SmartRegionRestrictions.allows("Standard Push-Ups", excluding: [.knee]))
        #expect(!SmartRegionRestrictions.allows("Standard Push-Ups", excluding: [.wrist]))
        #expect(!SmartRegionRestrictions.allows("Calf Raises", excluding: [.foot]))
        #expect(SmartRegionRestrictions.allows("Calf Raises", excluding: [.knee]))
        #expect(!SmartRegionRestrictions.allows("Superman", excluding: [.back]))
        #expect(SmartRegionRestrictions.allows("Superman", excluding: [.elbow]))
        #expect(!SmartRegionRestrictions.allows("Side-Lying Hip Abduction", excluding: [.hip]))
        #expect(!SmartRegionRestrictions.allows("Pull-Ups", excluding: [.shoulder]))
        #expect(!SmartRegionRestrictions.allows("Barbell Bent-Over Row", excluding: [.back]))
        #expect(SmartRegionRestrictions.allows("Chest-Supported Dumbbell Row", excluding: [.back]))
        #expect(SmartRegionRestrictions.allows("Leg Extension", excluding: [.foot, .hip, .back, .shoulder, .elbow, .wrist]))
    }

    @Test func allRegionCombinationsRemainStrictDuringGenerationAndLoadOverrides() throws {
        let exercises = try BundledExerciseCatalog.load(from: #require(Bundle.main.url(forResource: "default", withExtension: "store")))
        let regions = SmartBodyRegion.allCases
        let generator = SmartSelectionGenerator()
        for mask in 1..<(1 << regions.count) {
            let selected = Set(regions.enumerated().filter { mask & (1 << $0.offset) != 0 }.map(\.element))
            let configuration = SmartWorkoutConfiguration(targetMuscleGroups: ["Full Body"], level: .advanced,
                equipmentMode: .standardGym, excludedRegions: selected)
            let plan = generator.plan(configuration: configuration, from: exercises)
            for exercise in exercises {
                let individuallyExcluded = selected.contains { !SmartRegionRestrictions.allows(exercise.name, excluding: [$0]) }
                if individuallyExcluded {
                    #expect(!generator.isEligible(exercise, configuration: configuration, ignoringLoads: true))
                    #expect(!plan.movements.contains { $0.exercise.name == exercise.name })
                }
            }
            if plan.movements.isEmpty { #expect(!plan.canStart) }
        }
    }
}
