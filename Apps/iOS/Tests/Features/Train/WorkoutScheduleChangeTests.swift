import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutScheduleChangeTests {
    @Test func scheduleRefreshFollowsSuccessfulWritesOnly() async {
        let repository = MockWorkoutRepository()
        let workout = WorkoutSnapshot(scheduledDays: ["Mon"])
        repository.stubbedWorkouts = [workout]
        var writesAtRefresh: [Int] = []
        let viewModel = SessionBuilderViewModel(
            workouts: repository, exercises: MockExerciseRepository(), workout: workout,
            onScheduleChanged: { writesAtRefresh.append(repository.savedWorkouts.count + repository.deletedIDs.count) }
        )
        viewModel.addMovement(ExerciseSnapshot())
        #expect(await viewModel.save())
        #expect(writesAtRefresh == [1])
        repository.shouldThrow = true
        #expect(await !viewModel.save())
        #expect(await !viewModel.deleteWorkout())
        #expect(writesAtRefresh == [1])
        repository.shouldThrow = false
        #expect(await viewModel.deleteWorkout())
        #expect(writesAtRefresh == [1, 2])
    }

    @Test func notificationFailureDoesNotFailWorkoutSave() async {
        let repository = MockWorkoutRepository()
        repository.stubbedWorkouts = [WorkoutSnapshot(scheduledDays: ["Sat"])]
        let client = MockWorkoutNotificationClient()
        client.failOnAdd = 1
        let reminders = WorkoutReminderCoordinator(
            preferences: WorkoutPreferences(areWorkoutRemindersEnabled: true),
            workouts: repository, notifications: client
        )
        let viewModel = SessionBuilderViewModel(
            workouts: repository, exercises: MockExerciseRepository(),
            onScheduleChanged: { await reminders.refresh() }
        )
        viewModel.addMovement(ExerciseSnapshot())
        #expect(await viewModel.save())
        #expect(repository.savedWorkouts.count == 1)
        #expect(viewModel.errorMessage == nil)
        #expect(reminders.errorMessage != nil)
        #expect(client.pending.isEmpty)
    }
}
