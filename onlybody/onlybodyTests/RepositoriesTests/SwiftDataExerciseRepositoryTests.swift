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
            Workout.self,
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

        #expect(allExercises.map(\.name) == ["Push-Ups", "Squats"])

        pushUp.frequencyPreference = ExerciseFrequency.more.rawValue
        try await repository.save(pushUp)

        let updatedExercises = try await repository.allExercises()
        #expect(updatedExercises.count == 2)
        #expect(updatedExercises.first { $0.name == "Push-Ups" }?.frequencyPreference == ExerciseFrequency.more.rawValue)
    }
}
