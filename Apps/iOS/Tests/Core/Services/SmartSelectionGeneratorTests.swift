import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartSelectionGeneratorTests {
    private func catalog() throws -> [ExerciseSnapshot] {
        try BundledExerciseCatalog.load(from: #require(Bundle.main.url(forResource: "default", withExtension: "store")))
    }

    @Test func repetitionProfilesLeaveFullCatalogIntact() throws {
        let exercises = try catalog()
        let nonRepetitions: Set<String> = ["Plank", "Side Plank", "Hollow Body Hold", "Wall Sit", "Short-Lever Copenhagen Plank",
            "Knee Side Plank", "Kneeling Plank", "Reverse Plank", "Dumbbell Farmer Carry", "Dumbbell Suitcase Carry"]
        #expect(Set(exercises.filter { $0.smartMetadata == nil }.map(\.name)) == Set(exercises.map(\.name)).intersection(nonRepetitions))
        for exercise in exercises where !nonRepetitions.contains(exercise.name) {
            let profile = try #require(exercise.smartMetadata)
            #expect(!profile.family.isEmpty)
            #expect(profile.repetitionSeconds > 0)
        }
    }

    @Test func selectionRespectsTimeEquipmentLoadsAndPrimaryTargets() throws {
        let exercises = try catalog()
        let generator = SmartSelectionGenerator()
        for minutes in [15, 30, 45, 60] {
            for target in ExerciseCatalog.sessionTargets {
                let configuration = SmartWorkoutConfiguration(targetMuscleGroups: [target], durationMinutes: minutes,
                    equipmentMode: .confirmed, excludedLoads: [.jumping, .overhead])
                let plan = generator.plan(configuration: configuration, from: exercises)
                #expect(plan.estimatedSeconds <= minutes * 60)
                #expect(Set(plan.movements.compactMap { $0.exercise.smartMetadata?.family }).count == plan.movements.count)
                #expect(plan.movements.allSatisfy { generator.isEligible($0.exercise, configuration: configuration) })
                if ExerciseCatalog.allMuscles.contains(target) {
                    #expect(plan.movements.allSatisfy { $0.exercise.primaryMuscles.contains(target) })
                }
                let roles = plan.movements.map { $0.exercise.smartMetadata?.role == .main ? 0 : 1 }
                #expect(roles == roles.sorted())
            }
        }
    }

    @Test func selectionDoesNotDependOnCatalogOrderAndPreservesMainExercises() throws {
        let exercises = try catalog()
        let configuration = SmartWorkoutConfiguration(targetMuscleGroups: ["Full Body"], durationMinutes: 60,
            equipmentMode: .standardGym)
        let generator = SmartSelectionGenerator()
        let first = generator.plan(configuration: configuration, from: exercises)
        let reversed = generator.plan(configuration: configuration, from: exercises.reversed())
        #expect(first.movements.map(\.exercise.name) == reversed.movements.map(\.exercise.name))
        let anchors = first.movements.filter { $0.exercise.smartMetadata?.role == .main }.map(\.exercise.name)
        let next = generator.plan(configuration: configuration, from: exercises,
            context: SmartGenerationContext(mainExerciseNames: anchors, previousExerciseNames: first.movements.map(\.exercise.name), variationSeed: 532))
        #expect(next.movements.filter { $0.exercise.smartMetadata?.role == .main }.map(\.exercise.name) == anchors)
    }

    @Test func regionRestrictionsNeverFallbackToExcludedExercises() throws {
        let exercises = try catalog()
        let configuration = SmartWorkoutConfiguration(targetMuscleGroups: ["Full Body"], excludedRegions: Set(SmartBodyRegion.allCases))
        let result = SmartSelectionGenerator().plan(configuration: configuration, from: exercises)
        #expect(result.movements.isEmpty)
        #expect(!result.canStart)
        #expect(Set(result.uncoveredNeeds) == ["Upper", "Lower", "Core", "variety"])
    }

    @Test func prescriptionsUseSharedDefaultsForMainAndAccessoryMovements() throws {
        let exercises = try catalog()
        let main = try #require(exercises.first { $0.smartMetadata?.role == .main })
        let accessory = try #require(exercises.first { $0.smartMetadata?.role == .accessory })
        let prescription = SmartPrescription()
        let first = prescription.movement(main)
        let second = prescription.movement(accessory)
        #expect(first.sets == 3 && first.reps == 10 && first.restSeconds == 90)
        #expect(second.sets == 2 && second.reps == 12 && second.restSeconds == 60)
        #expect(prescription.setRange == 2...3)
    }

    @Test func unilateralTimeIncludesBothSidesAndClockUsesLocalCivilDate() throws {
        let unilateral = try #require(try catalog().first { $0.smartMetadata?.repetitionRule == .perSide })
        let metadata = try #require(unilateral.smartMetadata)
        let movement = GeneratedMovement(exercise: unilateral, sets: 2, reps: 10, restSeconds: 60)
        #expect(SmartPrescription().seconds(movement) == metadata.setupSeconds + metadata.transitionSeconds + 2 * (20 * metadata.repetitionSeconds + 60))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(secondsFromGMT: -5 * 3600))
        let date = Date(timeIntervalSince1970: 1_762_041_600)
        let western = SmartPlanningClock(calendar: calendar).localDay(at: date)
        calendar.timeZone = try #require(TimeZone(secondsFromGMT: 9 * 3600))
        #expect(SmartPlanningClock(calendar: calendar).localDay(at: date) != western)
    }
}
