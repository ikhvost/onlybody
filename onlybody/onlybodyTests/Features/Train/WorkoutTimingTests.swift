import Foundation
import Testing
@testable import onlybody

@MainActor
struct WorkoutTimingTests {
    @Test func selectionDirtiesDraftAndAppliesToExistingAndNewMovements() async throws {
        let repository = MockWorkoutRepository()
        let model = SessionBuilderViewModel(workouts: repository, exercises: MockExerciseRepository())
        #expect(!model.hasUnsavedChanges)
        model.setDurationMinutes(35)
        #expect(model.hasUnsavedChanges)
        model.addMovement(ExerciseSnapshot(name: "Squats"))
        model.setDefaultRestSeconds(90)
        model.addMovement(ExerciseSnapshot(name: "Push-Ups"))
        #expect(model.movements.map(\.restSeconds) == [90, 90])
        #expect(await model.save())
        #expect(!model.hasUnsavedChanges)
        let saved = try #require(repository.savedWorkouts.first)
        #expect(saved.durationMinutes == 35)
        #expect(saved.restSeconds == 90)
        let edit = SessionBuilderViewModel(workouts: repository, exercises: MockExerciseRepository(), workout: saved)
        #expect(edit.durationMinutes == 35)
        #expect(edit.restSeconds == 90)
        #expect(!edit.hasUnsavedChanges)
        edit.setDurationMinutes(45)
        edit.setDefaultRestSeconds(60)
        #expect(await edit.save())
        #expect(repository.savedWorkouts.last?.id == saved.id)
        #expect(repository.savedWorkouts.last?.durationMinutes == 45)
        #expect(repository.savedWorkouts.last?.items.map(\.restSeconds) == [60, 60])
    }

    @Test func legacyMixedRestsStayIntactUntilUserAppliesDefault() {
        let exercise = ExerciseSnapshot(name: "Squats")
        let workout = WorkoutSnapshot(mode: "manual", items: [
            WorkoutItemSnapshot(restSeconds: 30, exercise: exercise),
            WorkoutItemSnapshot(restSeconds: 90, exercise: exercise)
        ])
        let model = SessionBuilderViewModel(workouts: MockWorkoutRepository(), exercises: MockExerciseRepository(), workout: workout)
        #expect(model.durationMinutes == 30)
        #expect(model.hasMixedRest)
        #expect(model.movements.map(\.restSeconds) == [30, 90])
        #expect(!model.hasUnsavedChanges)
        model.setDefaultRestSeconds(45)
        #expect(model.movements.map(\.restSeconds) == [45, 45])
        #expect(!model.hasMixedRest)
        #expect(model.hasUnsavedChanges)
    }

    @Test func smartGenerationUsesSelectedBudgetAndRest() async throws {
        let repository = MockWorkoutRepository()
        let generator = SmartWorkoutGenerator(randomSets: { _ in 3 }, randomReps: { _ in 10 }, randomRest: { _ in 15 })
        let model = SessionBuilderViewModel(workouts: repository, exercises: MockExerciseRepository(),
                                           targetMuscleGroups: ["Chest"], generator: generator)
        model.allExercises = (0..<30).map { ExerciseSnapshot(name: "Chest \($0)", primaryMuscle: "Chest", equipment: ["None"]) }
        model.setDurationMinutes(15)
        model.setDefaultRestSeconds(90)
        #expect(await model.save())
        let short = try #require(repository.savedWorkouts.last)
        #expect(short.items.count == 3) // 270 seconds per exercise; 900-second budget.
        #expect(short.items.allSatisfy { $0.restSeconds == 90 })
        model.setDurationMinutes(60)
        #expect(await model.save())
        #expect(repository.savedWorkouts.last?.items.count == 13)
    }

    @Test func editingSmartNamePreservesExistingSetsAndIndividualRests() async throws {
        let exercise = ExerciseSnapshot(name: "Squats")
        let workout = WorkoutSnapshot(name: "Original", mode: "smart", targetMuscleGroups: ["Quads"], items: [
            WorkoutItemSnapshot(sets: 4, restSeconds: 30, exercise: exercise),
            WorkoutItemSnapshot(sets: 2, restSeconds: 90, exercise: exercise)
        ])
        let repository = MockWorkoutRepository()
        let model = SessionBuilderViewModel(workouts: repository, exercises: MockExerciseRepository(), workout: workout)
        model.name = "Renamed"
        #expect(await model.save())
        let saved = try #require(repository.savedWorkouts.first)
        #expect(saved.items.map(\.id) == workout.items.map(\.id))
        #expect(saved.items.map(\.restSeconds) == [30, 90])
        #expect(saved.items.map(\.sets) == [4, 2])
    }

    @Test func invalidSelectionsDoNotMutateDraft() {
        let model = SessionBuilderViewModel(workouts: MockWorkoutRepository(), exercises: MockExerciseRepository())
        model.setDurationMinutes(0)
        model.setDurationMinutes(17)
        model.setDefaultRestSeconds(-15)
        #expect(model.durationMinutes == 30)
        #expect(model.restSeconds == 45)
        #expect(!model.hasUnsavedChanges)
    }

    @Test func activeWorkoutUsesSavedSetRest() async {
        let workout = WorkoutSnapshot(durationMinutes: 35, restSeconds: 90, items: [WorkoutItemSnapshot(sets: 2, restSeconds: 90)])
        let repository = MockWorkoutRepository()
        repository.stubbedWorkouts = [workout]
        let model = ActiveWorkoutViewModel(workouts: repository, sessions: MockSessionRepository(), workoutId: workout.id,
                                          time: ManualWorkoutTimeSource())
        await model.load()
        defer { model.cleanup() }
        model.markSetDone()
        #expect(model.restTimer.remainingSeconds == 90)
    }
}
