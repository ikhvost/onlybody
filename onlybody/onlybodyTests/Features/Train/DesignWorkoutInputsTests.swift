import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct DesignWorkoutInputsTests {
    @Test func bodyWeightRevealPersistsForTheExerciseAndInvalidInputBlocksCompletion() async {
        let repo = MockWorkoutRepository()
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot(sets: 2)])
        repo.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        let model = ActiveWorkoutViewModel(workouts: repo, sessions: sessions, workoutId: workout.id,
                                           time: ManualWorkoutTimeSource())
        await model.load()
        defer { model.cleanup() }
        #expect(!model.showsWeight)
        model.revealWeight()
        model.enterWeight("2,50", locale: Locale(identifier: "uk_UA"))
        #expect(model.currentWeight == 2.5)
        model.enterWeight("0")
        #expect(model.showsWeight)
        model.enterReps("")
        #expect(model.currentDisplayReps == 12)
        model.markSetDone()
        await model.endSession()
        #expect(model.completedSetCount == 0)
        #expect(!model.isComplete)
        model.enterReps("0")
        model.markSetDone()
        #expect(model.completedSetCount == 1)
        await model.endSession()
        #expect(sessions.savedSessions.count == 1)
        #expect(sessions.savedSessions.first?.items.first?.setReps == [0])
    }

    @Test func weightsProductAlwaysShowsWeightAndEmptyCompletionDoesNotWrite() async {
        let repo = MockWorkoutRepository()
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot()])
        repo.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        let model = ActiveWorkoutViewModel(workouts: repo, sessions: sessions, workoutId: workout.id,
                                           time: ManualWorkoutTimeSource(), alwaysShowsWeight: true)
        await model.load()
        #expect(model.showsWeight)
        await model.endSession()
        await model.retrySave()
        #expect(model.saveState == .noCompletedSets)
        #expect(model.canClose)
        #expect(sessions.savedSessions.isEmpty)
        model.cleanup()
        #expect(!AppConfiguration.onlyBody.alwaysShowsWeight)
        #expect(AppConfiguration.onlyWeights.alwaysShowsWeight)
    }

    @Test func builderKeepsCommittedValueOnInvalidInputAndNeverCreatesMissingID() async throws {
        let repo = MockWorkoutRepository()
        let model = SessionBuilderViewModel(workouts: repo, exercises: MockExerciseRepository())
        model.addMovement(ExerciseSnapshot(name: "Fixture"))
        let movement = try #require(model.movements.first)
        model.enterNumber("0", field: "Sets", id: movement.id)
        #expect(model.hasInvalidNumbers)
        #expect(model.movements.first?.sets == 3)
        #expect(await !model.save())
        model.enterNumber("4", field: "Sets", id: movement.id)
        #expect(!model.hasInvalidNumbers)
        #expect(await model.save())
        #expect(repo.savedWorkouts.first?.items.first?.sets == 4)
        let missing = SessionBuilderViewModel(workouts: repo, exercises: MockExerciseRepository(), workoutID: UUID())
        await missing.loadExercises()
        #expect(missing.errorMessage != nil)
        #expect(await !missing.save())
        #expect(repo.savedWorkouts.count == 1)
    }

    @Test func largeValidPlanDoesNotIterateUncompletedSetsOrOverflowEstimate() async throws {
        let repository = MockWorkoutRepository()
        let exercise = ExerciseSnapshot(name: "Fixture")
        let item = WorkoutItemSnapshot(sets: Int(Int32.max), restSeconds: Int(Int32.max), exercise: exercise)
        let workout = WorkoutSnapshot(items: [item, item, item])
        repository.stubbedWorkouts = [workout]
        let model = ActiveWorkoutViewModel(workouts: repository, sessions: MockSessionRepository(), workoutId: workout.id,
                                           time: ManualWorkoutTimeSource())
        await model.load()
        defer { model.cleanup() }
        model.markSetDone()
        #expect(model.completedSetsForCurrent == 1)
        #expect(model.buildSessionItems().first?.setReps == [12])
        let builder = SessionBuilderViewModel(workouts: repository, exercises: MockExerciseRepository(), workout: workout)
        #expect(builder.estimatedDurationSeconds == Int.max)
        #expect(builder.estimatedDurationMinutes > 0)
    }

    @Test func todayGroupingUsesInjectedDateAndDoesNotDuplicateWorkouts() async {
        let repo = MockWorkoutRepository()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let date = Date(timeIntervalSince1970: 0) // Thursday
        repo.stubbedWorkouts = [WorkoutSnapshot(name: "A", scheduledDays: ["Thu"]),
                               WorkoutSnapshot(name: "B", scheduledDays: ["Thu"]), WorkoutSnapshot(name: "C")]
        let model = TrainViewModel(workouts: repo, appName: "Fixture", now: { date }, calendar: calendar)
        await model.load()
        #expect(model.todaysWorkouts.map(\.name) == ["A", "B"])
        #expect(model.otherWorkouts.map(\.name) == ["C"])
    }
}
