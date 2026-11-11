import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartPlanAssessmentTests {
    private func catalog() throws -> [ExerciseSnapshot] {
        try BundledExerciseCatalog.load(from: #require(Bundle.main.url(forResource: "default", withExtension: "store")))
    }
    @Test func broadTargetsNeedVarietyButOneSpecificMuscleDoesNot() throws {
        let first = try #require(try catalog().first { $0.smartMetadata != nil })
        let item = WorkoutItemSnapshot(exercise: first)
        let broad = SmartWorkoutConfiguration(targetMuscleGroups: ["Upper"], level: .advanced, equipmentMode: .standardGym)
        #expect(SmartPlanAssessment(configuration: broad, items: [item]).status == .unavailable)
        let specific = SmartWorkoutConfiguration(targetMuscleGroups: [first.primaryMuscles[0]], level: .advanced, equipmentMode: .standardGym)
        #expect(SmartPlanAssessment(configuration: specific, items: [item]).status == .shorter)
        #expect(SmartPlanAssessment(configuration: broad, items: [item, item]).status == .unavailable)
    }

    @Test func timeExcludesOnlyFinalRestAndChangesWithOrder() throws {
        let exercises = try catalog().filter { $0.smartMetadata != nil }
        let first = try #require(exercises.first)
        let second = try #require(exercises.last)
        let items = [WorkoutItemSnapshot(sets: 2, targetReps: 10, restSeconds: 60, exercise: first),
                     WorkoutItemSnapshot(sets: 3, targetReps: 12, restSeconds: 90, exercise: second)]
        let prescription = SmartPrescription()
        let withAllRests = prescription.seconds(GeneratedMovement(exercise: first, sets: 2, reps: 10, restSeconds: 60))
            + prescription.seconds(GeneratedMovement(exercise: second, sets: 3, reps: 12, restSeconds: 90))
        #expect(prescription.seconds(items) == withAllRests - 90)
        #expect(prescription.seconds(items.reversed()) == prescription.seconds(items) + 30)
    }

    @Test func fullBodyRequiresEachRegionAndThreeDistinctExercises() {
        let policy = SmartTargetPolicy()
        let upper = ExerciseSnapshot(name: "Upper", primaryMuscle: "Chest")
        let lower = ExerciseSnapshot(name: "Lower", primaryMuscle: "Quads")
        let core = ExerciseSnapshot(name: "Core", primaryMuscle: "Core")
        #expect(policy.gaps(targets: ["Full Body"], exercises: [upper, lower, core]).isEmpty)
        #expect(policy.gaps(targets: ["Full Body"], exercises: [upper, lower]).contains("Core"))
        #expect(policy.gaps(targets: ["Chest", "Back"], exercises: [upper]) == ["Back"])
    }
}
