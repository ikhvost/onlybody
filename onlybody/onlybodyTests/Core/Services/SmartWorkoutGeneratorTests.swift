import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartWorkoutGeneratorTests {

    private func makeExercise(
        name: String,
        primaryMuscle: String,
        secondaryMuscles: [String] = [],
        equipment: [String] = ["None"],
        frequencyPreference: String = "normal"
    ) -> ExerciseSnapshot {
        var exercise = ExerciseSnapshot()
        exercise.name = name
        exercise.primaryMuscle = primaryMuscle
        exercise.secondaryMuscles = secondaryMuscles
        exercise.equipment = equipment
        exercise.frequencyPreference = frequencyPreference
        return exercise
    }

    private func deterministicGenerator(
        sets: Int,
        reps: Int,
        rest: Int
    ) -> SmartWorkoutGenerator {
        SmartWorkoutGenerator(
            randomSets: { _ in sets },
            randomReps: { _ in reps },
            randomRest: { _ in rest }
        )
    }

    // MARK: - Exclusion

    @Test
    func legacyExclusionDoesNotRemoveExercises() {
        let exercises = [
            makeExercise(name: "Push-Ups", primaryMuscle: "Chest"),
            makeExercise(name: "Skip", primaryMuscle: "Chest", frequencyPreference: "never"),
        ]
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.map(\.exercise.name) == ["Push-Ups", "Skip"])
    }

    // MARK: - Muscle Matching

    @Test
    func matchesOnlyTargetedMuscles() {
        let exercises = [
            makeExercise(name: "Push-Ups", primaryMuscle: "Chest"),
            makeExercise(name: "Squats", primaryMuscle: "Quads"),
            makeExercise(name: "Tricep Dips", primaryMuscle: "Arms", secondaryMuscles: ["Chest"]),
        ]
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)
        let names = result.map(\.exercise.name)

        // Push-Ups (primary match) and Tricep Dips (secondary match) are included
        // Squats (no match) is excluded
        #expect(names.contains("Push-Ups"))
        #expect(names.contains("Tricep Dips"))
        #expect(!names.contains("Squats"))
        #expect(result.count == 2)
    }

    @Test
    func matchesMultipleTargets() {
        let exercises = [
            makeExercise(name: "Push-Ups", primaryMuscle: "Chest"),
            makeExercise(name: "Squats", primaryMuscle: "Quads"),
            makeExercise(name: "Calf Raises", primaryMuscle: "Calves"),
        ]
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(
            targetMuscleGroups: ["Chest", "Quads"],
            durationMinutes: 60
        )

        let result = generator.generate(config: config, from: exercises)

        #expect(result.count == 2)
        let names = result.map(\.exercise.name)
        #expect(names.contains("Push-Ups"))
        #expect(names.contains("Squats"))
    }

    // MARK: - Aggregate Groups

    @Test
    func expandsFullBody() {
        let exercises = [
            makeExercise(name: "Push-Ups", primaryMuscle: "Chest"),
            makeExercise(name: "Squats", primaryMuscle: "Quads"),
        ]
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Full Body"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.count >= 2)
    }

    @Test
    func expandsUpper() {
        let exercises = [
            makeExercise(name: "Push-Ups", primaryMuscle: "Chest"),
            makeExercise(name: "Pull-Ups", primaryMuscle: "Back"),
            makeExercise(name: "Squats", primaryMuscle: "Quads"),
        ]
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Upper"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        let names = result.map(\.exercise.name)
        #expect(names.contains("Push-Ups"))
        #expect(names.contains("Pull-Ups"))
        #expect(!names.contains("Squats"))
    }

    @Test
    func expandsLower() {
        let exercises = [
            makeExercise(name: "Push-Ups", primaryMuscle: "Chest"),
            makeExercise(name: "Squats", primaryMuscle: "Quads"),
            makeExercise(name: "Glute Bridge", primaryMuscle: "Glutes"),
        ]
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Lower"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        let names = result.map(\.exercise.name)
        #expect(names.contains("Squats"))
        #expect(names.contains("Glute Bridge"))
        #expect(!names.contains("Push-Ups"))
    }

    // MARK: - Preference Ordering

    @Test
    func legacyPreferencesDoNotReorderExercises() {
        let exercises = [
            makeExercise(name: "Less", primaryMuscle: "Chest", frequencyPreference: "less"),
            makeExercise(name: "More", primaryMuscle: "Chest", frequencyPreference: "more"),
            makeExercise(name: "Normal", primaryMuscle: "Chest", frequencyPreference: "normal"),
        ]
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.count >= 3)
        #expect(result.map(\.exercise.name) == ["Less", "More", "Normal"])
    }

    @Test
    func keepsAllMatchingExercises() {
        let exercises = [
            makeExercise(name: "Keep", primaryMuscle: "Chest", frequencyPreference: "more"),
            makeExercise(name: "AlsoKeep", primaryMuscle: "Chest", frequencyPreference: "normal"),
        ]
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.count >= 2)
        #expect(result[0].exercise.name == "Keep")
    }

    // MARK: - Duration Budget

    @Test
    func respectsDurationBudget() {
        let exercises = [
            makeExercise(name: "Ex1", primaryMuscle: "Chest"),
            makeExercise(name: "Ex2", primaryMuscle: "Chest"),
            makeExercise(name: "Ex3", primaryMuscle: "Chest"),
            makeExercise(name: "Ex4", primaryMuscle: "Chest"),
        ]
        // 3 sets * 30 + 2 * 45 = 180s per exercise
        // Budget = 6 min = 360s → fits 2 exercises exactly
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 6)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.count == 2)
    }

    @Test
    func firstItemAlwaysIncludedRegardlessOfBudget() {
        let exercises = [
            makeExercise(name: "Ex1", primaryMuscle: "Chest"),
            makeExercise(name: "Ex2", primaryMuscle: "Chest"),
        ]
        // Each exercise = 3*30 + 2*45 = 180s
        // Budget = 1 min = 60s → only first fits (is always included)
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 1)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.count == 1)
    }

    @Test
    func includesItemWhenExactlyAtBudget() {
        let exercises = [
            makeExercise(name: "Ex1", primaryMuscle: "Chest"),
            makeExercise(name: "Ex2", primaryMuscle: "Chest"),
        ]
        // 3*30 + 2*45 = 180s per exercise
        // Budget = 360s = exactly 2 exercises
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 6)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.count == 2)
    }

    // MARK: - Fallback

    @Test
    func fallbackUsesEquipmentFreeWhenTooFewMatches() {
        let exercises = [
            makeExercise(name: "ChestBodyweight", primaryMuscle: "Chest", equipment: ["None"]),
            makeExercise(name: "BackBarbell", primaryMuscle: "Back", equipment: ["Barbell"]),
        ]
        // Only ChestBodyweight matches Chest → 1 match → fallback triggers
        // Fallback: equipment-free + Chest filter → ChestBodyweight → 1 item
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.count >= 1)
        #expect(result[0].exercise.name == "ChestBodyweight")
    }

    @Test
    func legacyExclusionDoesNotEmptyBodyweightPool() {
        let exercises = [
            makeExercise(name: "Never Bodyweight", primaryMuscle: "Chest", equipment: ["None"], frequencyPreference: "never"),
            makeExercise(name: "Barbell Only", primaryMuscle: "Chest", equipment: ["Barbell"]),
        ]
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        // Both matching exercises remain eligible regardless of legacy preferences.
        let names = result.map(\.exercise.name)
        #expect(names.contains("Never Bodyweight"))
    }

    @Test
    func returnsEmptyWhenNoExercisesMatch() {
        let exercises: [ExerciseSnapshot] = []
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.isEmpty)
    }

    // MARK: - Generated Values

    @Test
    func usesProvidedRandomClosures() {
        let exercises = [
            makeExercise(name: "Push-Ups", primaryMuscle: "Chest"),
        ]
        let generator = SmartWorkoutGenerator(
            randomSets: { _ in 4 },
            randomReps: { _ in 15 },
            randomRest: { _ in 60 }
        )
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.count >= 1)
        #expect(result[0].sets == 4)
        #expect(result[0].reps == 15)
        #expect(result[0].restSeconds == 60)
    }

    // MARK: - Edge Cases

    @Test
    func keepsOriginalOrderRegardlessOfLegacyPreference() {
        let exercises = [
            makeExercise(name: "Second", primaryMuscle: "Chest", frequencyPreference: "normal"),
            makeExercise(name: "First", primaryMuscle: "Chest", frequencyPreference: "more"),
            makeExercise(name: "Third", primaryMuscle: "Chest", frequencyPreference: "normal"),
        ]
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.map(\.exercise.name) == ["Second", "First", "Third"])
    }

    @Test
    func bodyweightSelectionDoesNotFavorLegacyMorePreference() {
        let exercises = [
            makeExercise(name: "Less Bodyweight", primaryMuscle: "Chest", equipment: ["None"], frequencyPreference: "less"),
            makeExercise(name: "More Bodyweight", primaryMuscle: "Chest", equipment: ["None"], frequencyPreference: "more"),
            makeExercise(name: "BackBarbell", primaryMuscle: "Back", equipment: ["Barbell"]),
        ]
        // Only Less Bodyweight and More Bodyweight match Chest → 2 in pool → no fallback
        let generator = deterministicGenerator(sets: 3, reps: 10, rest: 45)
        let config = SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"], durationMinutes: 60)

        let result = generator.generate(config: config, from: exercises)

        #expect(result.count >= 2)
        #expect(result[0].exercise.name == "Less Bodyweight")
        #expect(result[1].exercise.name == "More Bodyweight")
    }
}
