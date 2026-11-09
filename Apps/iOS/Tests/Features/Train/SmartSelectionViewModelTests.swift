import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartSelectionViewModelTests {
    @Test func multipleProblemsPersistAndChangesInvalidateTheDailyVariant() async throws {
        let workouts = MockWorkoutRepository()
        let variants = MockSmartDailyVariantRepository()
        let repository = try exercises()
        let model = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            preferences: WorkoutPreferences(), targets: ["Chest"], equipmentMode: .standardGym)
        await model.load()
        model.configuration.excludedLoads = [.jumping]
        model.toggleRegion(.knee)
        model.toggleRegion(.hip)
        model.toggleRegion(.hip)
        #expect(model.configuration.excludedRegions == [.knee])
        model.toggleRegion(.hip)
        await model.preview()
        let saved = try #require(await model.save())
        workouts.stubbedWorkouts = [saved]
        let reopened = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            preferences: WorkoutPreferences(), workoutID: saved.id, opensPreview: true)
        await reopened.load()
        #expect(reopened.configuration.excludedRegions == [.knee, .hip])
        #expect(reopened.configuration.excludedLoads == [.jumping])
        #expect(reopened.variant == model.variant)
        reopened.toggleRegion(.hip)
        await reopened.preview()
        #expect(reopened.variant?.settingsRevision != model.variant?.settingsRevision)
        reopened.removeLegacyLoad(.jumping)
        #expect(reopened.configuration.excludedRegions == [.knee])
        #expect(reopened.configuration.excludedLoads.isEmpty)
        reopened.toggleRegion(.shoulder)
        await reopened.preview()
        #expect(!reopened.canStart)
        #expect(!reopened.gaps.isEmpty)
        #expect(await reopened.save() == nil)
    }

    private func exercises() throws -> MockExerciseRepository {
        let repository = MockExerciseRepository()
        repository.stubbedAllExercises = try BundledExerciseCatalog.load(
            from: #require(Bundle.main.url(forResource: "default", withExtension: "store")))
        return repository
    }

    @Test func backStepsPreserveDraftAndOnlyActualEditsRequireDiscard() async throws {
        let viewModel = SmartSelectionViewModel(workouts: MockWorkoutRepository(), exercises: try exercises(),
            variants: MockSmartDailyVariantRepository(), preferences: WorkoutPreferences(), targets: ["Chest"], equipmentMode: .standardGym)
        await viewModel.load()
        #expect(!viewModel.hasUnsavedChanges)
        #expect(!viewModel.hasPreviousStep)
        viewModel.name = "Keep my draft"
        viewModel.showConditions()
        #expect(viewModel.hasPreviousStep)
        await viewModel.goBack()
        #expect(viewModel.stage == .setup)
        #expect(viewModel.name == "Keep my draft")
        #expect(viewModel.hasUnsavedChanges)
        viewModel.showConditions()
        await viewModel.preview()
        await viewModel.goBack()
        #expect(viewModel.stage == .conditions)
        await viewModel.preview()
        viewModel.edit()
        #expect(viewModel.hasPreviousStep)
        await viewModel.goBack()
        #expect(viewModel.stage == .preview)
        #expect(viewModel.name == "Keep my draft")
    }

    @Test func savedPreviewExitsWithoutDiscardAndEditingReturnsToPreview() async throws {
        let workouts = MockWorkoutRepository()
        let variants = MockSmartDailyVariantRepository()
        let repository = try exercises()
        let creator = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            preferences: WorkoutPreferences(), targets: ["Chest"], equipmentMode: .standardGym)
        await creator.load()
        await creator.preview()
        let saved = try #require(await creator.save())
        workouts.stubbedWorkouts = [saved]
        let reopened = SmartSelectionViewModel(workouts: workouts, exercises: repository, variants: variants,
            preferences: WorkoutPreferences(), workoutID: saved.id, opensPreview: true)
        await reopened.load()
        #expect(!reopened.hasPreviousStep)
        #expect(!reopened.hasUnsavedChanges)
        reopened.edit()
        reopened.name = "Edited name"
        #expect(reopened.hasPreviousStep)
        await reopened.goBack()
        #expect(reopened.stage == .preview)
        #expect(reopened.hasUnsavedChanges)
        #expect(reopened.name == "Edited name")
        reopened.edit()
        reopened.configuration.targetMuscleGroups = []
        await reopened.goBack()
        #expect(reopened.stage == .preview)
        #expect(!reopened.canStart)
        #expect(!reopened.gaps.isEmpty)
    }

    @Test func savesSettingsAndReviewedVariantThenReopensIdenticalDay() async throws {
        let workouts = MockWorkoutRepository()
        let variants = MockSmartDailyVariantRepository()
        let exercises = try exercises()
        let preferences = WorkoutPreferences()
        let now = Date()
        let viewModel = SmartSelectionViewModel(workouts: workouts, exercises: exercises, variants: variants,
            preferences: preferences, targets: ["Chest"], equipmentMode: .standardGym, now: { now })
        await viewModel.load()
        viewModel.name = "Daily chest"
        viewModel.configuration.level = .advanced
        viewModel.scheduledDays = ["Mon"]
        await viewModel.preview()
        let reviewed = try #require(viewModel.variant)
        let saved = try #require(await viewModel.save())
        #expect(saved.items == reviewed.items)
        #expect(saved.smartSettings?.configuration.level == .advanced)
        #expect(saved.scheduledDays == ["Mon"])
        #expect(preferences.smartLevel == .advanced)
        #expect(variants.writes.last == reviewed)
        workouts.stubbedWorkouts = [saved]
        let reopened = SmartSelectionViewModel(workouts: workouts, exercises: exercises, variants: variants,
            preferences: preferences, workoutID: saved.id, opensPreview: true, now: { now })
        await reopened.load()
        #expect(reopened.variant == reviewed)
        #expect(reopened.canStart)
    }

    @Test func sessionReplacementPersistsTodayWithoutChangingFutureAnchors() async throws {
        let workouts = MockWorkoutRepository()
        let variants = MockSmartDailyVariantRepository()
        let viewModel = SmartSelectionViewModel(workouts: workouts, exercises: try exercises(), variants: variants,
            preferences: WorkoutPreferences(), targets: ["Chest"], equipmentMode: .standardGym)
        await viewModel.load()
        viewModel.configuration.level = .advanced
        await viewModel.preview()
        let saved = try #require(await viewModel.save())
        let item = try #require(saved.items.first)
        let replacements = SmartReplacementViewModel(item: item, items: saved.items,
            configuration: viewModel.configuration, catalog: viewModel.catalog)
        replacements.equipmentUnavailable = false
        let replacement = try #require(replacements.alternatives.first)
        await viewModel.replace(item.id, with: replacement)
        #expect(variants.writes.last?.items.first?.exercise?.name == replacement.name)
        let replaced = try #require(await viewModel.save())
        #expect(replaced.smartSettings?.mainExerciseNames == saved.smartSettings?.mainExerciseNames)
        #expect(replaced.items.first?.exercise?.name == replacement.name)
        await viewModel.exclude(replacement)
        #expect(workouts.savedWorkouts.last?.smartSettings?.configuration.excludedExercises.contains(replacement.name) == true)
    }

    @Test func savingFailureKeepsDraftAndDoesNotRememberLevel() async throws {
        let workouts = MockWorkoutRepository()
        let preferences = WorkoutPreferences()
        let viewModel = SmartSelectionViewModel(workouts: workouts, exercises: try exercises(), variants: MockSmartDailyVariantRepository(),
            preferences: preferences, targets: ["Chest"], equipmentMode: .standardGym)
        await viewModel.load()
        viewModel.configuration.level = .advanced
        await viewModel.preview()
        workouts.shouldThrow = true
        #expect(await viewModel.save() == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.variant != nil)
        #expect(preferences.smartLevel == .beginner)
    }

    @Test func changedRevisionRegeneratesAndIncompleteVariantCannotSave() async throws {
        let workouts = MockWorkoutRepository()
        let viewModel = SmartSelectionViewModel(workouts: workouts, exercises: try exercises(), variants: MockSmartDailyVariantRepository(),
            preferences: WorkoutPreferences(), targets: ["Chest"], equipmentMode: .standardGym)
        await viewModel.load()
        await viewModel.preview()
        let first = try #require(viewModel.variant)
        viewModel.configuration.excludedExercises = Set(viewModel.catalog.map(\.name))
        await viewModel.preview()
        #expect(viewModel.variant?.settingsRevision != first.settingsRevision)
        #expect(!viewModel.canStart)
        #expect(await viewModel.save() == nil)
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
