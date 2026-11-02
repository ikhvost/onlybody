import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor struct WorkoutHistoryDefaultsTests {
    @Test func duplicateExerciseDefaultsStayWithTheirIDsWhenReordered() async {
        let exercise = ExerciseSnapshot(name: "Fixture press")
        let first = WorkoutItemSnapshot(order: 0, exercise: exercise)
        let second = WorkoutItemSnapshot(order: 1, exercise: exercise)
        let workout = WorkoutSnapshot(items: [first, second])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        sessions.stubbedSessions = [SessionSnapshot(items: [
            SessionItemSnapshot(order: 0, exerciseName: exercise.name, setReps: [8], setWeightsKg: [50]),
            SessionItemSnapshot(order: 1, exerciseName: exercise.name, setReps: [6], setWeightsKg: [60])
        ])]
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id)
        await model.load()
        model.moveExercise(first.id, to: second.id)
        #expect(model.row(WorkoutSetID(itemID: first.id, index: 0)).weightKg == 50)
        #expect(model.row(WorkoutSetID(itemID: second.id, index: 0)).reps == 6)
    }

    @Test func newSessionStartsWithLastRepsAndWeightForEachSet() async {
        let exercise = ExerciseSnapshot(name: "Fixture press")
        let item = WorkoutItemSnapshot(sets: 3, targetReps: 12, exercise: exercise)
        let workout = WorkoutSnapshot(items: [item])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        sessions.stubbedSessions = [SessionSnapshot(items: [
            SessionItemSnapshot(exerciseName: exercise.name, setReps: [8, 6], setWeightsKg: [50, 55])
        ])]
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id)
        await model.load()
        #expect(model.row(WorkoutSetID(itemID: item.id, index: 0)).reps == 8)
        #expect(model.row(WorkoutSetID(itemID: item.id, index: 0)).weightKg == 50)
        #expect(model.row(WorkoutSetID(itemID: item.id, index: 1)).reps == 6)
        #expect(model.row(WorkoutSetID(itemID: item.id, index: 2)).weightKg == 55)
        #expect(model.completedSetCount == 0)
        #expect(model.showsWeight)
        #expect(workouts.stubbedWorkouts.first?.items.first?.targetReps == 12)
        #expect(workouts.savedWorkouts.isEmpty)
    }

    @Test func retryOnlyUpdatesUntouchedRowsAndKeepsCompletedResults() async {
        let exercise = ExerciseSnapshot(name: "Fixture press")
        let item = WorkoutItemSnapshot(sets: 2, exercise: exercise)
        let workout = WorkoutSnapshot(items: [item])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id, time: ManualWorkoutTimeSource())
        await model.load()
        model.beginSession()
        defer { model.cleanup() }
        let key = WorkoutSetID(itemID: item.id, index: 0)
        model.enterReps("9", for: key)
        model.enterWeight("0", for: key)
        model.toggleSet(key)
        sessions.stubbedSessions = [SessionSnapshot(items: [
            SessionItemSnapshot(exerciseName: exercise.name, setReps: [8], setWeightsKg: [50])
        ])]
        await model.loadPreviousPerformances()
        #expect(model.row(key).reps == 9)
        #expect(model.row(key).weightKg == 0)
        #expect(model.row(key).isDone)
        #expect(model.row(WorkoutSetID(itemID: item.id, index: 1)).weightKg == 50)
        #expect(model.restTimer.remainingSeconds == item.restSeconds)
    }

    @Test func legacyExerciseWeightIsOnlyUsedAsANewSessionDefault() async {
        let exercise = ExerciseSnapshot(name: "Fixture press")
        let item = WorkoutItemSnapshot(exercise: exercise)
        let workout = WorkoutSnapshot(items: [item])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        sessions.stubbedSessions = [SessionSnapshot(items: [
            SessionItemSnapshot(exerciseName: exercise.name, setReps: [8], weightKg: 50)
        ])]
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id)
        await model.load()
        #expect(model.row(WorkoutSetID(itemID: item.id, index: 0)).weightKg == 50)
        #expect(sessions.stubbedSessions.first?.items.first?.weightForSet(at: 0) == nil)
    }

    @Test func unavailableHistoryDoesNotBlockTrainingAndCanBeRetried() async {
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot(exercise: ExerciseSnapshot(name: "Fixture press"))])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        sessions.shouldThrow = true
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id, time: ManualWorkoutTimeSource())
        await model.load()
        #expect(model.historyErrorMessage != nil)
        #expect(!model.items.isEmpty)
        model.beginSession()
        defer { model.cleanup() }
        #expect(model.hasStarted)
        sessions.shouldThrow = false
        await model.loadPreviousPerformances()
        #expect(model.historyErrorMessage == nil)
    }
}
