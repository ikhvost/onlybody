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

    @Test func thirtyMinuteFullBodyUsesAtLeastNinetyPercentAtEveryLevel() throws {
        for level in ExerciseDifficulty.ratedLevels {
            let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Full Body"], durationMinutes: 30,
                level: level, equipmentMode: .standardGym)
            let result = SmartSelectionGenerator().plan(configuration: config, from: try catalog())
            #expect(result.status == .complete)
            #expect((1620...1800).contains(result.estimatedSeconds))
        }
    }

    @Test func footRestrictionCanUseAccessoryExercisesForLegs() throws {
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Lower"], durationMinutes: 30,
            level: .beginner, equipmentMode: .standardGym, excludedRegions: [.foot])
        let result = SmartSelectionGenerator().plan(configuration: config, from: try catalog())
        #expect(result.movements.allSatisfy { $0.exercise.smartMetadata?.role == .accessory })
        #if ONLYWEIGHTS
        #expect(result.status != .unavailable)
        #expect(result.movements.count >= 2)
        #expect(result.uncoveredNeeds.isEmpty)
        #else
        // The remaining beginner bodyweight options target only Glutes, not two lower-body groups.
        #expect(result.status == .unavailable)
        var focused = config
        focused.targetMuscleGroups = ["Glutes"]
        #expect(SmartSelectionGenerator().plan(configuration: focused, from: try catalog()).status != .unavailable)
        #endif
    }

    @Test func restrictionAndDurationMatrixPreservesCoverageAndSetBounds() throws {
        let catalog = try catalog()
        for level in ExerciseDifficulty.ratedLevels {
            for minutes in [15, 30, 45, 60] {
                for regions: Set<SmartBodyRegion> in [[], [.foot], [.knee], [.foot, .knee]] {
                    let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Lower"], durationMinutes: minutes,
                        level: level, equipmentMode: .standardGym, excludedRegions: regions)
                    let result = SmartSelectionGenerator().plan(configuration: config, from: catalog)
                    #expect(result.estimatedSeconds <= minutes * 60)
                    #expect(result.movements.allSatisfy {
                        SmartSelectionGenerator().isEligible($0.exercise, configuration: config)
                            && SmartPrescription().setRange(level: level).contains($0.sets)
                    })
                    if result.status != .unavailable {
                        #expect(SmartTargetPolicy().gaps(targets: ["Lower"], exercises: result.movements.map(\.exercise)).isEmpty)
                    }
                    if result.status == .shorter { #expect(result.estimatedSeconds * 10 < minutes * 60 * 9) }
                }
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

    @Test func excludingAnAnchorStillAllowsAnotherMainExerciseForTheMissingTarget() throws {
        let exercises = try catalog()
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest", "Back"], durationMinutes: 30,
            level: .advanced, equipmentMode: .standardGym)
        let first = SmartSelectionGenerator().plan(configuration: config, from: exercises)
        let anchors = first.movements.filter { $0.exercise.smartMetadata?.role == .main }.map(\.exercise.name)
        let chest = first.movements.filter { $0.exercise.primaryMuscles.contains("Chest") }.map(\.exercise.name)
        var changed = config
        changed.excludedExercises = Set(chest)
        let next = SmartSelectionGenerator().plan(configuration: changed, from: exercises,
            context: SmartGenerationContext(mainExerciseNames: anchors.filter { !chest.contains($0) }))
        #expect(next.status != .unavailable)
        #expect(next.movements.contains { $0.exercise.primaryMuscles.contains("Chest") })
        #expect(!next.movements.contains { chest.contains($0.exercise.name) })
    }

    @Test func individualTargetsNeverFillTimeWithUnrelatedExercises() throws {
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest", "Back", "Shoulders"], durationMinutes: 30,
            level: .advanced, equipmentMode: .standardGym)
        let result = SmartSelectionGenerator().plan(configuration: config, from: try catalog())
        #expect(result.status != .unavailable)
        #expect(result.movements.allSatisfy { !Set($0.exercise.primaryMuscles).isDisjoint(with: config.targetMuscleGroups) })
        let reverse = SmartSelectionGenerator().plan(configuration: config, from: try catalog().reversed())
        #expect(result.movements.map(\.exercise.name) == reverse.movements.map(\.exercise.name))
        #expect(result.movements.map(\.sets) == reverse.movements.map(\.sets))
    }
}
