import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutModeEditingTests {
    @Test(arguments: [WorkoutMode.manual, .smart])
    func editingPreservesModeEvenWithoutTargets(_ mode: WorkoutMode) async throws {
        let repository = MockWorkoutRepository()
        let workout = WorkoutSnapshot(mode: mode.rawValue, items: [WorkoutItemSnapshot(exercise: ExerciseSnapshot())])
        let model = SessionBuilderViewModel(workouts: repository, exercises: MockExerciseRepository(), workout: workout)

        #expect(model.mode == mode)
        #expect(!model.hasUnsavedChanges)
        model.name = "Updated workout"
        #expect(await model.save())
        let saved = try #require(repository.savedWorkouts.last)
        #expect(saved.mode == mode.rawValue)
        #expect(saved.id == workout.id)
    }

    @Test(arguments: [WorkoutMode.manual, .smart])
    func loadingByIDRestoresMode(_ mode: WorkoutMode) async {
        let repository = MockWorkoutRepository()
        let workout = WorkoutSnapshot(mode: mode.rawValue)
        repository.stubbedWorkouts = [workout]
        let model = SessionBuilderViewModel(workouts: repository, exercises: MockExerciseRepository(), workoutID: workout.id)

        #expect(!model.hasUnsavedChanges)
        await model.loadExercises()

        #expect(model.mode == mode)
        #expect(!model.hasUnsavedChanges)
    }
}
