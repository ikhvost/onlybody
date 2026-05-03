import Foundation
import Testing
@testable import onlybody

@MainActor
struct ActiveWorkoutViewModelTests {

    private func makeExercise(name: String) -> Exercise {
        let exercise = Exercise()
        exercise.name = name
        exercise.primaryMuscle = "Full Body"
        return exercise
    }

    private func makeWorkoutItem(
        order: Int,
        sets: Int,
        targetReps: Int,
        restSeconds: Int,
        exercise: Exercise
    ) -> WorkoutItem {
        let item = WorkoutItem()
        item.order = order
        item.sets = sets
        item.targetReps = targetReps
        item.restSeconds = restSeconds
        item.exercise = exercise
        return item
    }

    private func makeWorkout(id: UUID, name: String, items: [WorkoutItem]) -> Workout {
        let workout = Workout()
        workout.id = id
        workout.name = name
        workout.items = items
        return workout
    }

    private func makeViewModel(
        workout: Workout
    ) -> (ActiveWorkoutViewModel, MockWorkoutRepository, MockSessionRepository) {
        let workoutRepo = MockWorkoutRepository()
        workoutRepo.stubbedWorkouts = [workout]
        let sessionRepo = MockSessionRepository()
        let viewModel = ActiveWorkoutViewModel(
            workouts: workoutRepo,
            sessions: sessionRepo,
            workoutId: workout.id
        )
        return (viewModel, workoutRepo, sessionRepo)
    }

    // MARK: - Load

    @Test
    func loadFetchesWorkoutAndSortsItemsByOrder() async {
        let pushUps = makeExercise(name: "Push-Ups")
        let squats = makeExercise(name: "Squats")

        let items = [
            makeWorkoutItem(order: 1, sets: 3, targetReps: 10, restSeconds: 45, exercise: squats),
            makeWorkoutItem(order: 0, sets: 4, targetReps: 12, restSeconds: 60, exercise: pushUps),
        ]

        let workout = makeWorkout(id: UUID(), name: "Test Workout", items: items)
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()

        #expect(viewModel.workoutName == "Test Workout")
        #expect(viewModel.items.count == 2)
        #expect(viewModel.items[0].exercise?.name == "Push-Ups")
        #expect(viewModel.items[1].exercise?.name == "Squats")
        #expect(viewModel.currentExerciseIndex == 0)
        #expect(viewModel.currentSetIndex == 0)
        #expect(!viewModel.isComplete)
    }

    @Test
    func loadSetsErrorWhenWorkoutNotFound() async {
        let (viewModel, _, _) = makeViewModel(workout: makeWorkout(id: UUID(), name: "Gone", items: []))

        await viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }

    // MARK: - Set Advancement

    @Test
    func markSetDoneAdvancesToNextSetWithinSameExercise() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 3, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()

        #expect(viewModel.currentSetIndex == 0)

        viewModel.markSetDone()

        #expect(viewModel.currentSetIndex == 1)
        #expect(viewModel.currentExerciseIndex == 0)
        #expect(!viewModel.isComplete)
    }

    @Test
    func markSetDoneRecordsCompletedSet() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()

        #expect(viewModel.completedSets["0-0"] == 10)
        #expect(viewModel.completedSetsForCurrent == 1)
    }

    @Test
    func markSetDoneRecordsAdjustedReps() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.incrementReps()
        viewModel.incrementReps()
        viewModel.markSetDone()

        #expect(viewModel.completedSets["0-0"] == 12)
    }

    @Test
    func markSetDoneCarriesForwardRepsToNextSet() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 3, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.incrementReps()

        #expect(viewModel.currentDisplayReps == 11)

        viewModel.markSetDone()

        #expect(viewModel.currentSetIndex == 1)
        #expect(viewModel.currentDisplayReps == 11)
    }

    // MARK: - Exercise Advancement

    @Test
    func markSetDoneAdvancesToNextExerciseAfterLastSet() async {
        let pushUps = makeExercise(name: "Push-Ups")
        let squats = makeExercise(name: "Squats")

        let items = [
            makeWorkoutItem(order: 0, sets: 1, targetReps: 10, restSeconds: 45, exercise: pushUps),
            makeWorkoutItem(order: 1, sets: 2, targetReps: 8, restSeconds: 60, exercise: squats),
        ]

        let workout = makeWorkout(id: UUID(), name: "Test", items: items)
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()

        #expect(viewModel.currentExerciseIndex == 1)
        #expect(viewModel.currentSetIndex == 0)
        #expect(viewModel.currentExerciseName == "Squats")
        #expect(!viewModel.isComplete)
    }

    @Test
    func markSetDoneCompletesAfterFinalSetOfFinalExercise() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 1, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()

        #expect(viewModel.isComplete)
    }

    // MARK: - Rest Timer Integration

    @Test
    func markSetDoneStartsRestTimerBetweenSets() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 3, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()

        #expect(viewModel.restTimer.isActive)
        #expect(viewModel.restTimer.remainingSeconds == 45)
        #expect(viewModel.restTimer.nextExerciseName == "")
    }

    @Test
    func markSetDoneStartsRestTimerBetweenExercisesUsingExerciseRestSeconds() async {
        let pushUps = makeExercise(name: "Push-Ups")
        let squats = makeExercise(name: "Squats")

        let items = [
            makeWorkoutItem(order: 0, sets: 1, targetReps: 10, restSeconds: 45, exercise: pushUps),
            makeWorkoutItem(order: 1, sets: 2, targetReps: 8, restSeconds: 60, exercise: squats),
        ]

        let workout = makeWorkout(id: UUID(), name: "Test", items: items)
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()

        #expect(viewModel.restTimer.isActive)
        #expect(viewModel.restTimer.remainingSeconds == 60)
        #expect(viewModel.restTimer.nextExerciseName == "Squats")
    }

    // MARK: - Navigation

    @Test
    func previousExerciseGoesBackAndResetsSetIndex() async {
        let pushUps = makeExercise(name: "Push-Ups")
        let squats = makeExercise(name: "Squats")

        let items = [
            makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: pushUps),
            makeWorkoutItem(order: 1, sets: 2, targetReps: 8, restSeconds: 60, exercise: squats),
        ]

        let workout = makeWorkout(id: UUID(), name: "Test", items: items)
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.skipExercise()

        #expect(viewModel.currentExerciseIndex == 1)

        viewModel.previousExercise()

        #expect(viewModel.currentExerciseIndex == 0)
        #expect(viewModel.currentSetIndex == 0)
    }

    @Test
    func skipExerciseMovesForward() async {
        let pushUps = makeExercise(name: "Push-Ups")
        let squats = makeExercise(name: "Squats")

        let items = [
            makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: pushUps),
            makeWorkoutItem(order: 1, sets: 2, targetReps: 8, restSeconds: 60, exercise: squats),
        ]

        let workout = makeWorkout(id: UUID(), name: "Test", items: items)
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.skipExercise()

        #expect(viewModel.currentExerciseIndex == 1)
        #expect(viewModel.currentSetIndex == 0)
    }

    @Test
    func cannotGoPreviousOnFirstExercise() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()

        #expect(!viewModel.canGoPrevious)
        #expect(!viewModel.canSkip)
    }

    @Test
    func canSkipOnNonLastExercise() async {
        let pushUps = makeExercise(name: "Push-Ups")
        let squats = makeExercise(name: "Squats")

        let items = [
            makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: pushUps),
            makeWorkoutItem(order: 1, sets: 2, targetReps: 8, restSeconds: 60, exercise: squats),
        ]

        let workout = makeWorkout(id: UUID(), name: "Test", items: items)
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()

        #expect(viewModel.canSkip)
        #expect(!viewModel.canGoPrevious)
    }

    // MARK: - Reps Stepper

    @Test
    func incrementRepsIncreasesDisplayReps() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.incrementReps()

        #expect(viewModel.currentDisplayReps == 11)
    }

    @Test
    func decrementRepsDecreasesDisplayReps() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.decrementReps()

        #expect(viewModel.currentDisplayReps == 9)
    }

    @Test
    func decrementRepsNeverGoesBelowZero() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 2, targetReps: 1, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.decrementReps()
        viewModel.decrementReps()

        #expect(viewModel.currentDisplayReps == 0)
    }

    // MARK: - Weight Stepper

    @Test
    func weightStartsAtZero() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()

        #expect(viewModel.currentWeight == 0)
    }

    @Test
    func incrementWeightAddsTwoPointFive() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.incrementWeight()

        #expect(viewModel.currentWeight == 2.5)
    }

    @Test
    func decrementWeightNeverGoesBelowZero() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.decrementWeight()

        #expect(viewModel.currentWeight == 0)
    }

    @Test
    func weightIsPerExercise() async {
        let pushUps = makeExercise(name: "Push-Ups")
        let squats = makeExercise(name: "Squats")

        let items = [
            makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: pushUps),
            makeWorkoutItem(order: 1, sets: 2, targetReps: 8, restSeconds: 60, exercise: squats),
        ]

        let workout = makeWorkout(id: UUID(), name: "Test", items: items)
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.incrementWeight()
        viewModel.incrementWeight()

        #expect(viewModel.currentWeight == 5.0)

        viewModel.skipExercise()

        #expect(viewModel.currentWeight == 0)
    }

    // MARK: - Session Items

    @Test
    func buildSessionItemsCreatesItemsForEachExercise() async {
        let pushUps = makeExercise(name: "Push-Ups")
        let squats = makeExercise(name: "Squats")

        let items = [
            makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: pushUps),
            makeWorkoutItem(order: 1, sets: 1, targetReps: 8, restSeconds: 60, exercise: squats),
        ]

        let workout = makeWorkout(id: UUID(), name: "Test", items: items)
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()

        viewModel.markSetDone()
        viewModel.markSetDone()
        viewModel.markSetDone()

        let sessionItems = viewModel.buildSessionItems()

        #expect(sessionItems.count == 2)
        #expect(sessionItems[0].exerciseName == "Push-Ups")
        #expect(sessionItems[0].plannedSets == 2)
        #expect(sessionItems[0].setReps.count == 2)
        #expect(sessionItems[1].exerciseName == "Squats")
        #expect(sessionItems[1].setReps.count == 1)
    }

    @Test
    func buildSessionItemsIncludesWeight() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 1, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.incrementWeight()
        viewModel.markSetDone()

        let sessionItems = viewModel.buildSessionItems()

        #expect(sessionItems[0].weightKg == 2.5)
    }

    // MARK: - Cleanup

    @Test
    func cleanupStopsElapsedAndRestTimers() async {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 3, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, _) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()
        viewModel.cleanup()

        #expect(!viewModel.restTimer.isActive)
    }

    // MARK: - Session Save

    @Test
    func markSetDoneOnFinalSetSavesExactlyOneSession() async throws {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 1, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Full Body", items: [item])
        let (viewModel, _, sessionRepo) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()

        #expect(viewModel.isComplete)

        await viewModel.saveTask?.value

        #expect(sessionRepo.savedSessions.count == 1)
        let saved = try #require(sessionRepo.savedSessions.first)
        #expect(saved.workoutName == "Full Body")
        #expect(saved.durationSeconds == viewModel.elapsedSeconds)
        #expect(saved.date.timeIntervalSince1970 > 0)
    }

    @Test
    func savedSessionUsesWorkoutNameSnapshot() async throws {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 1, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Snapshot Name", items: [item])
        let (viewModel, _, sessionRepo) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()
        await viewModel.saveTask?.value

        let saved = try #require(sessionRepo.savedSessions.first)
        #expect(saved.workoutName == "Snapshot Name")
    }

    @Test
    func savedSessionItemsUseExerciseNameSnapshots() async throws {
        let pushUps = makeExercise(name: "Push-Ups")
        let squats = makeExercise(name: "Squats")

        let items = [
            makeWorkoutItem(order: 0, sets: 1, targetReps: 10, restSeconds: 45, exercise: pushUps),
            makeWorkoutItem(order: 1, sets: 1, targetReps: 8, restSeconds: 60, exercise: squats),
        ]

        let workout = makeWorkout(id: UUID(), name: "Test", items: items)
        let (viewModel, _, sessionRepo) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()
        viewModel.skipExercise()
        viewModel.markSetDone()
        await viewModel.saveTask?.value

        let saved = try #require(sessionRepo.savedSessions.first)
        let sortedItems = saved.items?.sorted { $0.order < $1.order }
        #expect(sortedItems?.count == 2)
        #expect(sortedItems?[0].exerciseName == "Push-Ups")
        #expect(sortedItems?[1].exerciseName == "Squats")
    }

    @Test
    func savedSessionItemOrderMatchesWorkoutItemOrder() async throws {
        let pushUps = makeExercise(name: "Push-Ups")
        let squats = makeExercise(name: "Squats")

        let items = [
            makeWorkoutItem(order: 1, sets: 1, targetReps: 10, restSeconds: 45, exercise: squats),
            makeWorkoutItem(order: 0, sets: 1, targetReps: 8, restSeconds: 60, exercise: pushUps),
        ]

        let workout = makeWorkout(id: UUID(), name: "Test", items: items)
        let (viewModel, _, sessionRepo) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()
        viewModel.skipExercise()
        viewModel.markSetDone()
        await viewModel.saveTask?.value

        let saved = try #require(sessionRepo.savedSessions.first)
        #expect(saved.workoutName == "Test")
        let sortedItems = saved.items?.sorted { $0.order < $1.order }
        #expect(sortedItems?[0].order == 0)
        #expect(sortedItems?[1].order == 1)
    }

    @Test
    func savedSetRepsLengthMatchesCompletedSets() async throws {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 3, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, sessionRepo) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()
        viewModel.markSetDone()
        viewModel.markSetDone()
        await viewModel.saveTask?.value

        let saved = try #require(sessionRepo.savedSessions.first)
        let sessionItems = saved.items?.sorted { $0.order < $1.order }
        #expect(sessionItems?[0].setReps == [10, 10, 10])
    }

    @Test
    func savedWeightUsesActiveWorkoutWeightValue() async throws {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 1, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])
        let (viewModel, _, sessionRepo) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.incrementWeight()
        viewModel.incrementWeight()
        viewModel.markSetDone()
        await viewModel.saveTask?.value

        let saved = try #require(sessionRepo.savedSessions.first)
        let sessionItems = saved.items?.sorted { $0.order < $1.order }
        #expect(sessionItems?[0].weightKg == 5.0)
    }


    @Test
    func saveFailureSetsErrorMessage() async throws {
        let exercise = makeExercise(name: "Push-Ups")
        let item = makeWorkoutItem(order: 0, sets: 1, targetReps: 10, restSeconds: 45, exercise: exercise)
        let workout = makeWorkout(id: UUID(), name: "Test", items: [item])

        let workoutRepo = MockWorkoutRepository()
        workoutRepo.stubbedWorkouts = [workout]
        let sessionRepo = MockSessionRepository()
        sessionRepo.shouldThrow = true
        let viewModel = ActiveWorkoutViewModel(
            workouts: workoutRepo,
            sessions: sessionRepo,
            workoutId: workout.id
        )

        await viewModel.load()
        viewModel.markSetDone()
        await viewModel.saveTask?.value

        #expect(viewModel.errorMessage == "Could not save session.")
        #expect(viewModel.isComplete)
    }

    @Test
    func endSessionSavesAvailableCompletedData() async throws {
        let pushUps = makeExercise(name: "Push-Ups")
        let squats = makeExercise(name: "Squats")

        let items = [
            makeWorkoutItem(order: 0, sets: 2, targetReps: 10, restSeconds: 45, exercise: pushUps),
            makeWorkoutItem(order: 1, sets: 2, targetReps: 8, restSeconds: 60, exercise: squats),
        ]

        let workout = makeWorkout(id: UUID(), name: "Partial", items: items)
        let (viewModel, _, sessionRepo) = makeViewModel(workout: workout)

        await viewModel.load()
        viewModel.markSetDone()

        await viewModel.endSession()

        #expect(sessionRepo.savedSessions.count == 1)
        let saved = try #require(sessionRepo.savedSessions.first)
        #expect(saved.workoutName == "Partial")

        let sessionItems = saved.items?.sorted { $0.order < $1.order }
        #expect(sessionItems?.count == 2)
        #expect(sessionItems?[0].setReps == [10])
        #expect(sessionItems?[1].setReps.isEmpty == true)
    }
}
