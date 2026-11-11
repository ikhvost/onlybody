import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartSelectionQualityTests {
    private func catalog() throws -> [ExerciseSnapshot] {
        try BundledExerciseCatalog.load(from: #require(Bundle.main.url(forResource: "default", withExtension: "store")))
    }

    @Test func thirtyMinuteFullBodyUsesAtLeastNinetyPercent() throws {
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Full Body"], durationMinutes: 30,
            equipmentMode: .standardGym)
        let result = SmartSelectionGenerator().plan(configuration: config, from: try catalog())
        #expect(result.status == .complete)
        #expect((1620...1800).contains(result.estimatedSeconds))
    }

    @Test func footRestrictionCanUseAccessoryExercisesForLegs() throws {
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Lower"], durationMinutes: 30,
            equipmentMode: .standardGym, excludedRegions: [.foot])
        let result = SmartSelectionGenerator().plan(configuration: config, from: try catalog())
        #expect(result.movements.allSatisfy { $0.exercise.smartMetadata?.role == .accessory })
        #expect(result.status != .unavailable)
        #expect(result.movements.count >= 2)
        #expect(result.uncoveredNeeds.isEmpty)
        #expect(result.movements.allSatisfy { SmartRegionRestrictions.allows($0.exercise.name, excluding: [.foot]) })
    }

    @Test func restrictionAndDurationMatrixPreservesCoverageAndSetBounds() throws {
        let catalog = try catalog()
        for minutes in [15, 30, 45, 60] {
            for regions: Set<SmartBodyRegion> in [[], [.foot], [.knee], [.foot, .knee]] {
                let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Lower"], durationMinutes: minutes,
                    equipmentMode: .standardGym, excludedRegions: regions)
                let result = SmartSelectionGenerator().plan(configuration: config, from: catalog)
                #expect(result.estimatedSeconds <= minutes * 60)
                #expect(result.movements.allSatisfy {
                    SmartSelectionGenerator().isEligible($0.exercise, configuration: config)
                        && SmartPrescription().setRange.contains($0.sets)
                })
                if result.status != .unavailable {
                    #expect(SmartTargetPolicy().gaps(targets: ["Lower"], exercises: result.movements.map(\.exercise)).isEmpty)
                }
                if result.status == .shorter { #expect(result.estimatedSeconds * 10 < minutes * 60 * 9) }
            }
        }
    }

    @Test func tooManyRestrictionsGiveExplicitUnavailability() throws {
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Lower"], equipmentMode: .standardGym,
            excludedRegions: Set(SmartBodyRegion.allCases))
        let result = SmartSelectionGenerator().plan(configuration: config, from: try catalog())
        #expect(result.status == .unavailable)
        #expect(result.uncoveredNeeds.contains("Lower"))
        #expect(!result.canStart)
    }

    @Test func legacyExclusionsHaveNoEffectOnGeneration() throws {
        let exercises = try catalog()
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest", "Back"], durationMinutes: 30,
            equipmentMode: .standardGym)
        let first = SmartSelectionGenerator().plan(configuration: config, from: exercises)
        var legacy = config
        legacy.excludedExercises = Set(exercises.map(\.name))
        let next = SmartSelectionGenerator().plan(configuration: legacy, from: exercises)
        #expect(next.movements.map(\.exercise.name) == first.movements.map(\.exercise.name))
        #expect(next.movements.map(\.sets) == first.movements.map(\.sets))
        #expect(next.movements.map(\.reps) == first.movements.map(\.reps))
        #expect(next.movements.map(\.restSeconds) == first.movements.map(\.restSeconds))
    }

    @Test func individualTargetsNeverFillTimeWithUnrelatedExercises() throws {
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest", "Back", "Shoulders"], durationMinutes: 30,
            equipmentMode: .standardGym)
        let result = SmartSelectionGenerator().plan(configuration: config, from: try catalog())
        #expect(result.status != .unavailable)
        #expect(result.movements.allSatisfy { !Set($0.exercise.primaryMuscles).isDisjoint(with: config.targetMuscleGroups) })
        let reverse = SmartSelectionGenerator().plan(configuration: config, from: try catalog().reversed())
        #expect(result.movements.map(\.exercise.name) == reverse.movements.map(\.exercise.name))
        #expect(result.movements.map(\.sets) == reverse.movements.map(\.sets))
    }
}
