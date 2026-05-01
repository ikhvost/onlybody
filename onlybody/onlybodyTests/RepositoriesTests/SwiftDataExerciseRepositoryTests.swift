import SwiftData
import Testing
@testable import onlybody

@MainActor
struct SwiftDataExerciseRepositoryTests {
    @Test
    func saveAndFetchExercises() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Exercise.self,
            WorkoutItem.self,
            configurations: configuration
        )
        let repository = SwiftDataExerciseRepository(context: container.mainContext)

        let squat = Exercise()
        squat.name = "Squats"
        squat.primaryMuscle = "Quads"
        squat.secondaryMuscles = ["Glutes"]
        squat.equipment = ["None"]

        let pushUp = Exercise()
        pushUp.name = "Push-Ups"
        pushUp.primaryMuscle = "Chest"
        pushUp.secondaryMuscles = ["Triceps"]
        pushUp.equipment = ["None"]

        try await repository.save(squat)
        try await repository.save(pushUp)

        let allExercises = try await repository.allExercises()
        let matchingExercises = try await repository.exercises(matching: "push")
        let chestExercises = try await repository.exercises(primaryMuscle: "Chest")

        #expect(allExercises.map(\.name) == ["Push-Ups", "Squats"])
        #expect(matchingExercises.map(\.name) == ["Push-Ups"])
        #expect(chestExercises.map(\.name) == ["Push-Ups"])

        pushUp.frequencyPreference = "more"
        try await repository.save(pushUp)

        let updatedExercises = try await repository.allExercises()
        #expect(updatedExercises.count == 2)
        #expect(updatedExercises.first { $0.name == "Push-Ups" }?.frequencyPreference == "more")
    }
}
