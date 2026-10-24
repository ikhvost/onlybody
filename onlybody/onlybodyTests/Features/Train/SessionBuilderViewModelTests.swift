import Foundation
import Testing
@testable import onlybody

@MainActor
struct SessionBuilderViewModelTests {

    // MARK: - Add Movement

    @Test
    func addMovementAppendsToMovementsList() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        var exercise = ExerciseSnapshot()
        exercise.name = "Push-Ups"
        exercise.primaryMuscle = "Chest"

        #expect(viewModel.movements.isEmpty)

        viewModel.addMovement(exercise)

        #expect(viewModel.movements.count == 1)
        #expect(viewModel.movements.first?.exercise.name == "Push-Ups")
        #expect(viewModel.movements.first?.sets == 3)
        #expect(viewModel.movements.first?.reps == 12)
        #expect(viewModel.movements.first?.restSeconds == 45)
    }

    @Test
    func addMultipleMovementsAppendsInOrder() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        var pushUps = ExerciseSnapshot()
        pushUps.name = "Push-Ups"

        var pullUps = ExerciseSnapshot()
        pullUps.name = "Pull-Ups"

        viewModel.addMovement(pushUps)
        viewModel.addMovement(pullUps)

        #expect(viewModel.movements.count == 2)
        #expect(viewModel.movements[0].exercise.name == "Push-Ups")
        #expect(viewModel.movements[1].exercise.name == "Pull-Ups")
    }

    // MARK: - Remove Movement

    @Test
    func removeMovementRemovesByID() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        var pushUps = ExerciseSnapshot()
        pushUps.name = "Push-Ups"

        var pullUps = ExerciseSnapshot()
        pullUps.name = "Pull-Ups"

        viewModel.addMovement(pushUps)
        viewModel.addMovement(pullUps)

        #expect(viewModel.movements.count == 2)

        let firstID = viewModel.movements[0].id
        viewModel.removeMovement(firstID)

        #expect(viewModel.movements.count == 1)
        #expect(viewModel.movements.first?.exercise.name == "Pull-Ups")
    }

    @Test
    func removeNonexistentMovementDoesNothing() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        var exercise = ExerciseSnapshot()
        exercise.name = "Push-Ups"
        viewModel.addMovement(exercise)

        viewModel.removeMovement(UUID())

        #expect(viewModel.movements.count == 1)
    }

    // MARK: - Sets / Reps / Rest

    @Test
    func setSetsUpdatesValue() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        let exercise = ExerciseSnapshot()
        viewModel.addMovement(exercise)
        let id = viewModel.movements[0].id

        viewModel.setSets(5, forMovement: id)
        #expect(viewModel.movements[0].sets == 5)
    }

    @Test
    func setSetsRespectsMinimumOfOne() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        let exercise = ExerciseSnapshot()
        viewModel.addMovement(exercise)
        let id = viewModel.movements[0].id

        viewModel.setSets(0, forMovement: id)
        #expect(viewModel.movements[0].sets == 1)

        viewModel.setSets(-5, forMovement: id)
        #expect(viewModel.movements[0].sets == 1)
    }

    @Test
    func setRepsUpdatesValue() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        let exercise = ExerciseSnapshot()
        viewModel.addMovement(exercise)
        let id = viewModel.movements[0].id

        viewModel.setReps(20, forMovement: id)
        #expect(viewModel.movements[0].reps == 20)
    }

    @Test
    func setRepsRespectsMinimumOfOne() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        let exercise = ExerciseSnapshot()
        viewModel.addMovement(exercise)
        let id = viewModel.movements[0].id

        viewModel.setReps(0, forMovement: id)
        #expect(viewModel.movements[0].reps == 1)
    }

    @Test
    func setRestUpdatesValue() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        let exercise = ExerciseSnapshot()
        viewModel.addMovement(exercise)
        let id = viewModel.movements[0].id

        viewModel.setRest(60, forMovement: id)
        #expect(viewModel.movements[0].restSeconds == 60)
    }

    @Test
    func setRestRespectsMinimumOfFifteen() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        let exercise = ExerciseSnapshot()
        viewModel.addMovement(exercise)
        let id = viewModel.movements[0].id

        viewModel.setRest(0, forMovement: id)
        #expect(viewModel.movements[0].restSeconds == 15)

        viewModel.setRest(-15, forMovement: id)
        #expect(viewModel.movements[0].restSeconds == 15)
    }

    // MARK: - Toggle Day

    @Test
    func toggleDayAddsDayToSchedule() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        #expect(viewModel.scheduledDays.isEmpty)

        viewModel.toggleDay("Mon")
        #expect(viewModel.scheduledDays == ["Mon"])

        viewModel.toggleDay("Wed")
        #expect(viewModel.scheduledDays == ["Mon", "Wed"])
    }

    @Test
    func toggleDayRemovesDayFromSchedule() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        viewModel.toggleDay("Mon")
        viewModel.toggleDay("Wed")
        #expect(viewModel.scheduledDays == ["Mon", "Wed"])

        viewModel.toggleDay("Mon")
        #expect(viewModel.scheduledDays == ["Wed"])
    }

    // MARK: - Estimated Duration

    @Test
    func estimatedDurationZeroWhenNoMovements() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        #expect(viewModel.estimatedDurationSeconds == 0)
        #expect(viewModel.estimatedDurationMinutes == 1)
    }

    @Test
    func estimatedDurationCalculatesCorrectly() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        let exercise = ExerciseSnapshot()
        viewModel.addMovement(exercise)
        // 3 sets × 30s + 2 rests × 45s = 90 + 90 = 180s
        #expect(viewModel.estimatedDurationSeconds == 180)
        #expect(viewModel.estimatedDurationMinutes == 3)
    }

    @Test
    func estimatedDurationUpdatesWhenSetsChange() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        let exercise = ExerciseSnapshot()
        viewModel.addMovement(exercise)
        let id = viewModel.movements[0].id

        viewModel.setSets(5, forMovement: id)
        // 5 sets × 30s + 4 rests × 45s = 150 + 180 = 330s
        #expect(viewModel.estimatedDurationSeconds == 330)
        #expect(viewModel.estimatedDurationMinutes == 6)
    }

    @Test
    func estimatedDurationUpdatesWhenRestChanges() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        let exercise = ExerciseSnapshot()
        viewModel.addMovement(exercise)
        let id = viewModel.movements[0].id

        viewModel.setRest(60, forMovement: id)
        // 3 sets × 30s + 2 rests × 60s = 90 + 120 = 210s
        #expect(viewModel.estimatedDurationSeconds == 210)
        #expect(viewModel.estimatedDurationMinutes == 4)
    }

    @Test
    func estimatedDurationWithMultipleMovements() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        var pushUps = ExerciseSnapshot()
        pushUps.name = "Push-Ups"
        viewModel.addMovement(pushUps)
        // 3 × 30 + 2 × 45 = 180

        var pullUps = ExerciseSnapshot()
        pullUps.name = "Pull-Ups"
        viewModel.addMovement(pullUps)
        // 3 × 30 + 2 × 45 = 180

        // Total: 180 + 180 = 360s = 6 min
        #expect(viewModel.estimatedDurationSeconds == 360)
        #expect(viewModel.estimatedDurationMinutes == 6)
    }

    // MARK: - Save (Create)

    @Test
    func saveCreateCallsRepositorySave() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        var exercise = ExerciseSnapshot()
        exercise.name = "Push-Ups"
        exercise.primaryMuscle = "Chest"

        viewModel.name = "Full Body"
        viewModel.mode = .manual
        viewModel.addMovement(exercise)
        viewModel.toggleDay("Mon")
        viewModel.toggleDay("Wed")

        let success = await viewModel.save()

        #expect(success == true)
        #expect(workoutRepo.savedWorkouts.count == 1)

        let savedWorkout = workoutRepo.savedWorkouts.first!
        #expect(savedWorkout.name == "Full Body")
        #expect(savedWorkout.mode == WorkoutMode.manual.rawValue)
        #expect(savedWorkout.scheduledDays == ["Mon", "Wed"])
        #expect(savedWorkout.items.count == 1)

        let savedItem = savedWorkout.items.first
        #expect(savedItem?.order == 0)
        #expect(savedItem?.sets == 3)
        #expect(savedItem?.targetReps == 12)
        #expect(savedItem?.restSeconds == 45)
        #expect(savedItem?.exercise?.name == "Push-Ups")
    }

    @Test
    func saveCreateWithEmptyNameUsesDefault() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        let exercise = ExerciseSnapshot()
        viewModel.addMovement(exercise)

        let success = await viewModel.save()

        #expect(success == true)
        let savedWorkout = workoutRepo.savedWorkouts.first!
        #expect(savedWorkout.name == "My Session")
    }

    @Test
    func saveCreateWithMultipleMovementsPreservesOrder() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        var pushUps = ExerciseSnapshot()
        pushUps.name = "Push-Ups"

        var pullUps = ExerciseSnapshot()
        pullUps.name = "Pull-Ups"

        var squats = ExerciseSnapshot()
        squats.name = "Squats"

        viewModel.addMovement(pushUps)
        viewModel.addMovement(pullUps)
        viewModel.addMovement(squats)

        _ = await viewModel.save()

        let savedWorkout = workoutRepo.savedWorkouts.first!
        let items = savedWorkout.items.sorted(by: { $0.order < $1.order })

        #expect(items.count == 3)
        #expect(items[0].order == 0)
        #expect(items[0].exercise?.name == "Push-Ups")
        #expect(items[1].order == 1)
        #expect(items[1].exercise?.name == "Pull-Ups")
        #expect(items[2].order == 2)
        #expect(items[2].exercise?.name == "Squats")
    }

    @Test
    func saveCreateFailsAndSetsErrorMessage() async {
        let workoutRepo = MockWorkoutRepository()
        workoutRepo.shouldThrow = true
        let exerciseRepo = MockExerciseRepository()
        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        let exercise = ExerciseSnapshot()
        viewModel.addMovement(exercise)

        let success = await viewModel.save()

        #expect(success == false)
        #expect(viewModel.errorMessage == "Could not save session.")
    }

    // MARK: - Save (Edit)

    @Test
    func saveEditUpdatesExistingWorkout() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()

        var existing = WorkoutSnapshot()
        existing.id = UUID()
        existing.name = "Old Name"
        existing.mode = WorkoutMode.smart.rawValue
        existing.scheduledDays = ["Mon"]

        var oldItem = WorkoutItemSnapshot()
        oldItem.order = 0
        oldItem.sets = 5
        oldItem.targetReps = 10
        oldItem.restSeconds = 60
        oldItem.exercise = ExerciseSnapshot()
        oldItem.exercise?.name = "Old Exercise"

        existing.items = [oldItem]

        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo,
            workout: existing
        )

        #expect(viewModel.name == "Old Name")
        #expect(viewModel.mode == .smart)
        #expect(viewModel.scheduledDays == ["Mon"])
        #expect(viewModel.movements.count == 1)

        var newExercise = ExerciseSnapshot()
        newExercise.name = "Push-Ups"
        viewModel.name = "Updated Name"
        viewModel.mode = .manual
        viewModel.scheduledDays = []
        viewModel.movements = []
        viewModel.addMovement(newExercise)
        viewModel.toggleDay("Fri")

        let success = await viewModel.save()

        #expect(success == true)
        #expect(existing.items == [oldItem])
        #expect(workoutRepo.savedWorkouts.count == 1)

        let savedWorkout = workoutRepo.savedWorkouts.first!
        #expect(savedWorkout.id == existing.id)
        #expect(savedWorkout.name == "Updated Name")
        #expect(savedWorkout.mode == WorkoutMode.manual.rawValue)
        #expect(savedWorkout.scheduledDays == ["Fri"])
        #expect(savedWorkout.items.count == 1)
        #expect(savedWorkout.items.first?.exercise?.name == "Push-Ups")
    }

    // MARK: - Load Exercises

    @Test
    func loadExercisesPopulatesAllExercises() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()

        var pushUps = ExerciseSnapshot()
        pushUps.name = "Push-Ups"

        var pullUps = ExerciseSnapshot()
        pullUps.name = "Pull-Ups"

        exerciseRepo.stubbedAllExercises = [pushUps, pullUps]

        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        await viewModel.loadExercises()

        #expect(viewModel.allExercises.count == 2)
        #expect(viewModel.allExercises.map(\.name).contains("Push-Ups"))
        #expect(viewModel.allExercises.map(\.name).contains("Pull-Ups"))
    }

    @Test
    func loadExercisesSetsErrorMessageOnFailure() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        exerciseRepo.shouldThrow = true

        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo
        )

        await viewModel.loadExercises()

        #expect(viewModel.allExercises.isEmpty)
        #expect(viewModel.errorMessage == "Could not load exercises.")
    }

    // MARK: - Smart Save

    @Test
    func smartSaveGeneratesMovementsAndSavesWorkout() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()

        var chestExercise = ExerciseSnapshot()
        chestExercise.name = "Push-Ups"
        chestExercise.primaryMuscle = "Chest"
        chestExercise.equipment = ["None"]

        var backExercise = ExerciseSnapshot()
        backExercise.name = "Pull-Ups"
        backExercise.primaryMuscle = "Back"
        backExercise.equipment = ["Pull-up Bar"]

        let deterministicGen = SmartWorkoutGenerator(
            randomSets: { _ in 3 },
            randomReps: { _ in 10 },
            randomRest: { _ in 45 }
        )

        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo,
            workout: nil,
            targetMuscleGroups: ["Chest", "Back"],
            generator: deterministicGen
        )

        viewModel.allExercises = [chestExercise, backExercise]
        viewModel.name = "Smart Chest & Back"
        viewModel.toggleDay("Mon")

        let success = await viewModel.save()

        #expect(success == true)
        #expect(workoutRepo.savedWorkouts.count == 1)

        let savedWorkout = workoutRepo.savedWorkouts.first!
        #expect(savedWorkout.name == "Smart Chest & Back")
        #expect(savedWorkout.mode == WorkoutMode.smart.rawValue)
        #expect(savedWorkout.targetMuscleGroups == ["Chest", "Back"])
        #expect(savedWorkout.scheduledDays == ["Mon"])

        let items = savedWorkout.items.sorted(by: { $0.order < $1.order })
        #expect(items.count >= 2)
    }

    @Test
    func smartSaveSetsErrorMessageWhenNoExercisesMatch() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let deterministicGen = SmartWorkoutGenerator(
            randomSets: { _ in 3 },
            randomReps: { _ in 10 },
            randomRest: { _ in 45 }
        )

        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo,
            workout: nil,
            targetMuscleGroups: ["Chest"],
            generator: deterministicGen
        )

        viewModel.allExercises = []
        viewModel.name = "Empty Smart"

        let success = await viewModel.save()

        #expect(success == false)
        #expect(viewModel.errorMessage == "No exercises match. Try different muscle groups.")
        #expect(workoutRepo.savedWorkouts.isEmpty)
    }

    @Test
    func smartSavePreservesManualModeWhenNoTargets() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()

        var exercise = ExerciseSnapshot()
        exercise.name = "Push-Ups"

        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo,
            workout: nil,
            targetMuscleGroups: []
        )

        viewModel.allExercises = [exercise]
        viewModel.mode = .manual
        viewModel.addMovement(exercise)

        let success = await viewModel.save()

        #expect(success == true)
        let savedWorkout = workoutRepo.savedWorkouts.first!
        #expect(savedWorkout.mode == WorkoutMode.manual.rawValue)
        #expect(savedWorkout.targetMuscleGroups.isEmpty)
        #expect(savedWorkout.items.count == 1)
    }

    @Test
    func smartSaveDefaultModeWhenTargetsProvided() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()
        let deterministicGen = SmartWorkoutGenerator(
            randomSets: { _ in 3 },
            randomReps: { _ in 10 },
            randomRest: { _ in 45 }
        )

        var chestExercise = ExerciseSnapshot()
        chestExercise.name = "Push-Ups"
        chestExercise.primaryMuscle = "Chest"
        chestExercise.equipment = ["None"]

        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo,
            workout: nil,
            targetMuscleGroups: ["Chest"],
            generator: deterministicGen
        )

        #expect(viewModel.mode == .smart)
    }

    @Test
    func editModePreservesTargetMuscleGroups() async {
        let workoutRepo = MockWorkoutRepository()
        let exerciseRepo = MockExerciseRepository()

        var existing = WorkoutSnapshot()
        existing.id = UUID()
        existing.name = "Old Smart"
        existing.mode = WorkoutMode.smart.rawValue
        existing.targetMuscleGroups = ["Chest", "Back"]

        let viewModel = SessionBuilderViewModel(
            workouts: workoutRepo,
            exercises: exerciseRepo,
            workout: existing
        )

        #expect(viewModel.targetMuscleGroups == ["Chest", "Back"])
        #expect(viewModel.mode == .smart)
    }
}
