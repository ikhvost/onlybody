import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartDailyEditingTests {
    private func context() -> SmartEditorContext {
        let exercise = ExerciseSnapshot(name: "Original", primaryMuscle: "Chest")
        let settings = SmartWorkoutSettings(configuration: SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"],
            durationMinutes: 15, excludedRegions: [.knee]), mainExerciseNames: [exercise.name])
        let workout = WorkoutSnapshot(name: "Daily", mode: WorkoutMode.smart.rawValue, targetMuscleGroups: ["Chest"],
            durationMinutes: 15, smartSettings: settings, items: [WorkoutItemSnapshot(exercise: exercise)])
        let daily = SmartDailyVariant(workoutID: workout.id, localDay: "2026-11-11", settingsRevision: settings.revision,
            items: workout.items, estimatedSeconds: 100, uncoveredNeeds: ["time"], createdAt: Date())
        return SmartEditorContext(workout: workout, variant: daily, isExisting: true, requiresSave: false)
    }

    @Test func allManualEditsAreLocalUntilAtomicSaveAndKeepFutureSettings() async throws {
        let context = context()
        let workouts = MockWorkoutRepository()
        let catalog = MockExerciseRepository()
        let replacement = ExerciseSnapshot(name: "Anything", primaryMuscle: "Quads", equipment: ["Barbell"])
        catalog.stubbedAllExercises = [replacement]
        let editor = SessionBuilderViewModel(workouts: workouts, exercises: catalog, smartContext: context)
        await editor.loadExercises()
        #expect(!editor.hasUnsavedChanges)
        let first = try #require(editor.movements.first)
        editor.replaceMovement(first.id, with: replacement)
        editor.setSets(100, forMovement: first.id)
        editor.setReps(20, forMovement: first.id)
        editor.addMovement(replacement) // Repeated families and exercises are also valid manual choices.
        let last = try #require(editor.movements.last)
        editor.moveMovement(last.id, to: first.id)
        editor.name = "Edited daily"
        editor.toggleDay("Mon")
        #expect(editor.hasUnsavedChanges)
        #expect(editor.canSave)
        #expect(editor.estimatedDurationMinutes > 15)
        #expect(workouts.savedWorkouts.isEmpty)
        #expect(workouts.savedVariants.isEmpty)
        #expect(await editor.save())
        let saved = try #require(workouts.savedWorkouts.last)
        let daily = try #require(workouts.savedVariants.last)
        #expect(saved.items == daily.items)
        #expect(saved.items.map(\.id) == [last.id, first.id])
        #expect(saved.items.map(\.order) == [0, 1])
        #expect(saved.items.last?.sets == 100)
        #expect(saved.smartSettings == context.workout.smartSettings)
        #expect(daily.localDay == context.variant.localDay)
        #expect(daily.settingsRevision == context.variant.settingsRevision)
        #expect(saved.scheduledDays == ["Mon"])
        #expect(editor.savedWorkout == saved)
        #expect(!editor.hasUnsavedChanges)
    }

    @Test func shortPlanCanSaveAndEmptyDraftCanBeRepairedManually() async throws {
        let context = context()
        let workouts = MockWorkoutRepository()
        let editor = SessionBuilderViewModel(workouts: workouts, exercises: MockExerciseRepository(), smartContext: context)
        #expect(editor.canSave)
        #expect(await editor.save())
        editor.removeMovement(try #require(editor.movements.first).id)
        #expect(!editor.canSave)
        #expect(await editor.save() == false)
        editor.addMovement(ExerciseSnapshot(name: "Plank", primaryMuscle: "Core"))
        #expect(editor.canSave)
        #expect(editor.estimatedDurationSeconds > 0)
        #expect(await editor.save())
        #expect(workouts.savedVariants.last?.items.count == 1)
    }

    @Test func invalidNumbersAndFailedSavePreserveDraftForRetry() async throws {
        let workouts = MockWorkoutRepository()
        let editor = SessionBuilderViewModel(workouts: workouts, exercises: MockExerciseRepository(), smartContext: context())
        let item = try #require(editor.movements.first)
        editor.beginRepsEditing(item.id)
        #expect(!editor.hasUnsavedChanges && editor.canSave)
        editor.enterNumber("8", field: "Reps", id: item.id)
        editor.enterNumber("", field: "Reps", id: item.id)
        editor.endNumberEditing()
        #expect(editor.movements.first?.reps == item.reps)
        #expect(!editor.hasUnsavedChanges && editor.canSave)
        editor.enterNumber("0", field: "Sets", id: item.id)
        #expect(!editor.canSave)
        #expect(await editor.save() == false)
        editor.restoreMovement(item)
        #expect(editor.canSave)
        #expect(!editor.hasUnsavedChanges)
        editor.enterNumber("0", field: "Rest", id: item.id)
        #expect(editor.canSave)
        workouts.shouldThrow = true
        #expect(await editor.save() == false)
        #expect(editor.errorMessage != nil)
        #expect(editor.hasUnsavedChanges)
        #expect(editor.movements.first?.restSeconds == 0)
        #expect(workouts.savedWorkouts.isEmpty)
        #expect(workouts.savedVariants.isEmpty)
        workouts.shouldThrow = false
        #expect(await editor.save())
        #expect(!editor.hasUnsavedChanges)
    }

    @Test func activeReplacementUsesFullCatalogButProtectsCompletedSets() async throws {
        let workout = context().workout
        let active = ActiveWorkoutViewModel(workouts: MockWorkoutRepository(), sessions: MockSessionRepository(),
                                            workoutId: workout.id, time: ManualWorkoutTimeSource(), reviewedWorkout: workout)
        await active.load()
        let item = try #require(active.items.first)
        let replacement = ExerciseSnapshot(name: "Any exercise", primaryMuscle: "Quads", equipment: ["Barbell"])
        active.replaceExercise(item.id, with: replacement)
        #expect(active.items.first?.exercise == replacement)
        active.markSetDone()
        active.replaceExercise(item.id, with: ExerciseSnapshot(name: "Blocked after completed set"))
        #expect(active.items.first?.exercise == replacement)
        active.cleanup()
    }

    @Test func legacyDailyPayloadWithoutAcceptanceStillDecodes() throws {
        let daily = context().variant
        let data = try JSONEncoder().encode(daily)
        #expect(try JSONDecoder().decode(SmartDailyVariant.self, from: data).acceptedShortPlan == nil)
    }
}
