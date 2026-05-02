import SwiftData
import Testing
@testable import onlybody

@MainActor
struct SwiftDataWorkoutRepositoryTests {
    @Test
    func saveAndFetchWorkouts() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Exercise.self,
            Workout.self,
            WorkoutItem.self,
            configurations: configuration
        )
        let repository = SwiftDataWorkoutRepository(context: container.mainContext)

        let fullBody = Workout()
        fullBody.name = "Full Body"
        fullBody.mode = "smart"
        fullBody.scheduledDays = ["Mon", "Wed", "Fri"]

        let upperBody = Workout()
        upperBody.name = "Upper Body"
        upperBody.mode = "manual"
        upperBody.scheduledDays = ["Tue", "Thu"]

        try await repository.save(fullBody)
        try await repository.save(upperBody)

        let all = try await repository.allWorkouts()
        #expect(all.map(\.name) == ["Full Body", "Upper Body"])
        #expect(all.first { $0.name == "Full Body" }?.scheduledDays == ["Mon", "Wed", "Fri"])
    }

    @Test
    func saveWorkoutWithItems() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Exercise.self,
            Workout.self,
            WorkoutItem.self,
            configurations: configuration
        )
        let workoutRepo = SwiftDataWorkoutRepository(context: container.mainContext)
        let exerciseRepo = SwiftDataExerciseRepository(context: container.mainContext)

        let pushUp = Exercise()
        pushUp.name = "Push-Ups"
        pushUp.primaryMuscle = "Chest"
        try await exerciseRepo.save(pushUp)

        let squat = Exercise()
        squat.name = "Squats"
        squat.primaryMuscle = "Quads"
        try await exerciseRepo.save(squat)

        let workout = Workout()
        workout.name = "Full Body"

        let item1 = WorkoutItem()
        item1.order = 0
        item1.sets = 3
        item1.targetReps = 12
        item1.exercise = pushUp

        let item2 = WorkoutItem()
        item2.order = 1
        item2.sets = 4
        item2.targetReps = 15
        item2.exercise = squat

        workout.items = [item1, item2]
        try await workoutRepo.save(workout)

        let all = try await workoutRepo.allWorkouts()
        #expect(all.count == 1)

        let fetched = all[0]
        #expect(fetched.name == "Full Body")
        #expect(fetched.items?.count == 2)

        let sorted = fetched.items?.sorted { $0.order < $1.order }
        #expect(sorted?[0].exercise?.name == "Push-Ups")
        #expect(sorted?[1].exercise?.name == "Squats")
        #expect(sorted?[0].sets == 3)
        #expect(sorted?[1].targetReps == 15)
    }

    @Test
    func updateWorkout() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Exercise.self,
            Workout.self,
            WorkoutItem.self,
            configurations: configuration
        )
        let repository = SwiftDataWorkoutRepository(context: container.mainContext)

        let workout = Workout()
        workout.name = "Original"
        workout.mode = "smart"
        try await repository.save(workout)

        workout.name = "Updated"
        workout.mode = "manual"
        workout.scheduledDays = ["Sat"]
        try await repository.save(workout)

        let all = try await repository.allWorkouts()
        #expect(all.count == 1)
        #expect(all[0].name == "Updated")
        #expect(all[0].mode == "manual")
        #expect(all[0].scheduledDays == ["Sat"])
    }

}
