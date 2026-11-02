import Foundation
import SwiftData
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SwiftDataExerciseRepositoryTests {
    @Test func metadataUpdatesPreserveStoredIdentityAndHistoryWithoutDuplicates() async throws {
        let container = try ModelContainer(
            for: Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let original = ExerciseSnapshot(name: "Stable fixture movement", primaryMuscle: "Chest", equipment: ["None"])
        let exerciseRepository = SwiftDataExerciseRepository(context: ModelContext(container))
        try await exerciseRepository.save(original)
        let workouts = SwiftDataWorkoutRepository(context: ModelContext(container))
        let workout = WorkoutSnapshot(name: "Existing routine", items: [WorkoutItemSnapshot(exercise: original)])
        try await workouts.save(workout)
        let sessions = SwiftDataSessionRepository(context: ModelContext(container))
        let history = SessionSnapshot(workoutName: workout.name, items: [
            SessionItemSnapshot(exerciseName: original.name, setReps: [12, 10], weightKg: 20)
        ])
        try await sessions.save(history)

        // A rebuilt release catalog has a different UUID but the same canonical key.
        let updated = ExerciseSnapshot(name: original.name, primaryMuscle: "Shoulders", equipment: ["Dumbbells"])
        #expect(updated.id != original.id)
        let catalog = SwiftDataExerciseRepository(context: ModelContext(container), catalog: [updated])
        let first = try #require(try await catalog.allExercises().first)
        #expect(first.id == original.id)
        #expect(first.name == original.name)
        #expect(first.primaryMuscle == updated.primaryMuscle)
        #expect(first.equipment == updated.equipment)
        #expect(try await catalog.allExercises() == [first])

        let updatedWorkouts = SwiftDataWorkoutRepository(context: ModelContext(container), catalog: [updated])
        var edited = workout
        edited.items[0].exercise = first
        try await updatedWorkouts.save(edited)
        let restored = try #require(try await updatedWorkouts.workout(by: workout.id))
        #expect(restored.items.first?.id == workout.items.first?.id)
        #expect(restored.items.first?.exercise?.id == original.id)
        #expect(try await sessions.allSessions() == [history])
        #expect(try ModelContext(container).fetchCount(FetchDescriptor<Exercise>()) == 1)
    }

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

        var squat = ExerciseSnapshot()
        squat.name = "Squats"
        squat.primaryMuscle = "Quads"
        squat.secondaryMuscles = ["Glutes"]
        squat.equipment = ["None"]

        var pushUp = ExerciseSnapshot()
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
