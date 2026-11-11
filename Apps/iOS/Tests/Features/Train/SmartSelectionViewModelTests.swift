import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartSelectionViewModelTests {
    private func exercises() throws -> MockExerciseRepository {
        let repository = MockExerciseRepository()
        repository.stubbedAllExercises = try BundledExerciseCatalog.load(
            from: #require(Bundle.main.url(forResource: "default", withExtension: "store")))
        return repository
    }

    @Test func generationAndBackStepsNeverWriteAndRetainRestrictions() async throws {
        let workouts = MockWorkoutRepository()
        let variants = MockSmartDailyVariantRepository()
        let model = SmartSelectionViewModel(workouts: workouts, exercises: try exercises(), variants: variants,
                                            targets: ["Chest"], equipmentMode: .standardGym)
        await model.load()
        #expect(!model.hasUnsavedChanges)
        model.showConditions()
        model.toggleRegion(.knee)
        model.toggleRegion(.hip)
        model.configuration.excludedLoads = [.jumping]
        model.goBack()
        #expect(model.stage == .setup)
        #expect(model.configuration.excludedRegions == [.knee, .hip])
        #expect(model.hasUnsavedChanges)
        model.showConditions()
        await model.preview()
        let first = try #require(model.editorContext)
        #expect(first.workout.smartSettings?.configuration.excludedLoads == [.jumping])
        #expect(first.requiresSave)
        #expect(workouts.savedWorkouts.isEmpty)
        #expect(variants.writes.isEmpty)
        model.edit()
        model.toggleRegion(.hip)
        await model.preview()
        #expect(model.editorContext?.variant.settingsRevision != first.variant.settingsRevision)
        #expect(model.editorContext?.workout.smartSettings?.configuration.excludedRegions == [.knee])
    }

    @Test func emptyGenerationStillOpensEditableDraft() async throws {
        let model = SmartSelectionViewModel(workouts: MockWorkoutRepository(), exercises: try exercises(),
            variants: MockSmartDailyVariantRepository(), targets: ["Full Body"], equipmentMode: .standardGym)
        await model.load()
        model.configuration.excludedRegions = Set(SmartBodyRegion.allCases)
        await model.preview()
        #expect(model.stage == .preview)
        #expect(model.editorContext?.variant.items.isEmpty == true)
    }

    @Test func openEditorRetainsItsDayButNewOpeningResolvesTheNextDay() async throws {
        let workouts = MockWorkoutRepository()
        let variants = MockSmartDailyVariantRepository()
        let repository = try exercises()
        var now = Date(timeIntervalSince1970: 1_762_050_000)
        let model = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            targets: ["Full Body"], equipmentMode: .standardGym, now: { now })
        await model.load()
        await model.preview()
        let first = try #require(model.editorContext)
        workouts.stubbedWorkouts = [first.workout]
        variants.variants = [first.variant]
        now = now.addingTimeInterval(86_400)
        await model.preview()
        #expect(model.editorContext?.variant == first.variant)
        let reopened = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            workoutID: first.workout.id, opensPreview: true, now: { now })
        await reopened.load()
        #expect(reopened.editorContext?.variant.localDay != first.variant.localDay)
        #expect(reopened.editorContext?.workout.smartSettings == first.workout.smartSettings)
        #expect(variants.writes.isEmpty)
    }

    @Test func cachedLegacyListIsNotRevalidatedOrReplaced() async throws {
        let repository = try exercises()
        let first = try #require(repository.stubbedAllExercises.first)
        let settings = SmartWorkoutSettings(configuration: SmartWorkoutConfiguration(
            targetMuscleGroups: ["Upper", "Chest"], excludedExercises: [first.name]))
        let workout = WorkoutSnapshot(name: "Legacy", smartSettings: settings, items: [WorkoutItemSnapshot(exercise: first)])
        let now = Date()
        let daily = SmartDailyVariant(workoutID: workout.id, localDay: SmartPlanningClock().localDay(at: now),
            settingsRevision: settings.revision, items: workout.items, estimatedSeconds: 1800,
            uncoveredNeeds: ["constraints"], createdAt: now, acceptedShortPlan: false)
        let variants = MockSmartDailyVariantRepository()
        variants.variants = [daily]
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        let model = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            workoutID: workout.id, opensPreview: true, now: { now })
        await model.load()
        let context = try #require(model.editorContext)
        #expect(context.variant == daily)
        let editor = SessionBuilderViewModel(workouts: workouts, exercises: repository, smartContext: context)
        await editor.loadExercises()
        #expect(editor.canSave)
        #expect(await editor.save())
        #expect(workouts.savedWorkouts.last?.items == daily.items)
        #expect(workouts.savedWorkouts.last?.smartSettings?.configuration == settings.configuration)
    }

    @Test func failedLoadCanRetryWithoutWriting() async throws {
        let exercises = try exercises()
        let workouts = MockWorkoutRepository()
        let variants = MockSmartDailyVariantRepository()
        exercises.shouldThrow = true
        let model = SmartSelectionViewModel(workouts: workouts, exercises: exercises, variants: variants, targets: ["Chest"])
        await model.load()
        #expect(model.errorMessage != nil)
        #expect(model.editorContext == nil)
        exercises.shouldThrow = false
        await model.retry()
        variants.shouldThrow = true
        await model.preview()
        #expect(model.errorMessage != nil)
        variants.shouldThrow = false
        await model.retry()
        #expect(model.editorContext != nil)
        #expect(workouts.savedWorkouts.isEmpty)
    }
    @Test func activeSessionUsesDetachedReviewedPlanAndStartsWeightsAtZero() async throws {
        let exercise = try #require(try exercises().stubbedAllExercises.first { $0.smartMetadata != nil })
        let item = WorkoutItemSnapshot(targetReps: 8, exercise: exercise)
        let reviewed = WorkoutSnapshot(name: "Reviewed", smartSettings: SmartWorkoutSettings(
            configuration: SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"])), items: [item])
        let workouts = MockWorkoutRepository()
        workouts.shouldThrow = true // Loading the active list must not re-read a changed template.
        let sessions = MockSessionRepository()
        sessions.stubbedSessions = [SessionSnapshot(items: [SessionItemSnapshot(
            exerciseName: exercise.name, setReps: [42], weightKg: 55, setWeightsKg: [55])])]
        let time = ManualWorkoutTimeSource()
        time.now = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86_390)
        let liveActivity = MockWorkoutLiveActivity()
        let active = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: reviewed.id,
                                            time: time, reviewedWorkout: reviewed, liveActivity: liveActivity)
        await active.load()
        #expect(active.items == reviewed.items)
        #expect(active.row(WorkoutSetID(itemID: item.id, index: 0)).weightKg == 0)
        #expect(active.row(WorkoutSetID(itemID: item.id, index: 0)).reps == 8)
        #expect(active.hasStarted)
        #expect(liveActivity.workoutName == reviewed.name)
        #expect(liveActivity.states.last?.exerciseName == exercise.displayName)
        #expect(liveActivity.states.last?.setNumber == 1)
        active.markSetDone()
        #expect(liveActivity.states.last?.setNumber == 2)
        #expect(liveActivity.states.last?.restDeadline == time.now.addingTimeInterval(TimeInterval(item.restSeconds)))
        time.advance(seconds: 120)
        active.synchronizeRest()
        await active.load()
        #expect(active.items == reviewed.items)
        #expect(liveActivity.states.last?.restDeadline == nil)
        active.cleanup()
        #expect(liveActivity.hasEnded)
    }
}
