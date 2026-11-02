import SwiftData
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

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

        var fullBody = WorkoutSnapshot()
        fullBody.name = "Full Body"
        fullBody.mode = WorkoutMode.smart.rawValue
        fullBody.scheduledDays = ["Mon", "Wed", "Fri"]
        fullBody.durationMinutes = 35
        fullBody.restSeconds = 90

        var upperBody = WorkoutSnapshot()
        upperBody.name = "Upper Body"
        upperBody.mode = WorkoutMode.manual.rawValue
        upperBody.scheduledDays = ["Tue", "Thu"]

        try await repository.save(fullBody)
        try await repository.save(upperBody)

        let all = try await repository.allWorkouts()
        #expect(all.map(\.name) == ["Full Body", "Upper Body"])
        #expect(all.first?.durationMinutes == 35)
        #expect(all.first?.restSeconds == 90)
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

        var pushUp = ExerciseSnapshot()
        pushUp.name = "Push-Ups"
        pushUp.primaryMuscle = "Chest"
        try await exerciseRepo.save(pushUp)

        var squat = ExerciseSnapshot()
        squat.name = "Squats"
        squat.primaryMuscle = "Quads"
        try await exerciseRepo.save(squat)

        var workout = WorkoutSnapshot()
        workout.name = "Full Body"

        var item1 = WorkoutItemSnapshot()
        item1.order = 0
        item1.sets = 3
        item1.targetReps = 12
        item1.exercise = pushUp

        var item2 = WorkoutItemSnapshot()
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
        #expect(fetched.items.count == 2)

        let sorted = fetched.items.sorted { $0.order < $1.order }
        #expect(sorted[0].exercise?.name == "Push-Ups")
        #expect(sorted[1].exercise?.name == "Squats")
        #expect(sorted[0].sets == 3)
        #expect(sorted[1].targetReps == 15)
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

        var workout = WorkoutSnapshot()
        workout.name = "Original"
        workout.mode = WorkoutMode.smart.rawValue
        try await repository.save(workout)

        workout.name = "Updated"
        workout.mode = WorkoutMode.manual.rawValue
        workout.scheduledDays = ["Sat"]
        try await repository.save(workout)

        let all = try await repository.allWorkouts()
        #expect(all.count == 1)
        #expect(all[0].name == "Updated")
        #expect(all[0].mode == WorkoutMode.manual.rawValue)
        #expect(all[0].scheduledDays == ["Sat"])
    }

}
