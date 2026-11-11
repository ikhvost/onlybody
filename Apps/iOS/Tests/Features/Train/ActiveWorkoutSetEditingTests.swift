import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct ActiveWorkoutSetEditingTests {
    private func makeModel(
        sets: Int = 2, twoExercises: Bool = false, smart: Bool = false,
        time: ManualWorkoutTimeSource = ManualWorkoutTimeSource(),
        activity: MockWorkoutLiveActivity? = nil, alerts: WorkoutRestAlerts? = nil
    ) async -> (ActiveWorkoutViewModel, MockWorkoutRepository, MockSessionRepository) {
        let workouts = MockWorkoutRepository()
        var items = [WorkoutItemSnapshot(sets: sets, targetReps: 12, restSeconds: 45, exercise: ExerciseSnapshot(name: "A"))]
        if twoExercises {
            items.append(WorkoutItemSnapshot(order: 1, sets: sets, restSeconds: 60, exercise: ExerciseSnapshot(name: "B")))
        }
        let settings = smart ? SmartWorkoutSettings(configuration: SmartWorkoutConfiguration(targetMuscleGroups: ["Chest"])) : nil
        let workout = WorkoutSnapshot(name: "Set editing", smartSettings: settings, items: items)
        workouts.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id,
            time: time, reviewedWorkout: smart ? workout : nil, restAlerts: alerts, liveActivity: activity)
        await model.load()
        return (model, workouts, sessions)
    }

    @Test func editingIsUnavailableBeforeStartAfterFinishAndAfterDiscard() async {
        let (model, _, _) = await makeModel()
        defer { model.cleanup() }
        #expect(!model.canAddSet && !model.canRemoveLastSet)
        #expect(model.addSet() == nil)
        model.removeLastSet()
        #expect(model.currentSetsTotal == 2)
        model.beginSession()
        #expect(model.canAddSet && model.canRemoveLastSet)
        await model.endSession()
        #expect(!model.canAddSet && !model.canRemoveLastSet)
        #expect(model.addSet() == nil)
        model.removeLastSet()
        #expect(model.currentSetsTotal == 2)

        let (discarded, _, _) = await makeModel()
        discarded.beginSession()
        #expect(discarded.discardSession())
        #expect(discarded.addSet() == nil)
        discarded.removeLastSet()
        #expect(discarded.currentSetsTotal == 2)
    }

    @Test(arguments: [false, true])
    func addedSetCopiesNumbersFromCompletedLastRowWithoutCompletionOrInputState(smart: Bool) async throws {
        let (model, workouts, _) = await makeModel(smart: smart)
        defer { model.cleanup() }
        model.beginSession()
        let item = model.items[0]
        let last = WorkoutSetID(itemID: item.id, index: 1)
        model.enterReps("8", for: last)
        model.enterWeight("30", for: last, locale: Locale(identifier: "en_US"))
        model.toggleSet(last)
        let added = try #require(model.addSet())
        #expect(added == WorkoutSetID(itemID: item.id, index: 2))
        #expect(model.currentSetsTotal == 3)
        let row = model.row(added)
        #expect(row.reps == 8 && row.weightKg == 30)
        #expect(!row.isDone && !row.invalidReps && !row.invalidWeight)
        #expect(row.repsInput == nil && row.weightInput == nil)
        #expect(model.row(last).isDone)
        #expect(model.completedSetCount == 1)
        #expect(model.canRemoveLastSet)
        #expect(workouts.savedWorkouts.isEmpty && workouts.savedVariants.isEmpty)
    }

    @Test func completedLastRowBlocksRemovalEvenWithEarlierUncompletedRows() async {
        let (model, _, _) = await makeModel(sets: 3)
        defer { model.cleanup() }
        model.beginSession()
        let item = model.items[0]
        let last = WorkoutSetID(itemID: item.id, index: 2)
        model.toggleSet(last)
        #expect(!model.canRemoveLastSet)
        model.removeLastSet()
        #expect(model.currentSetsTotal == 3)
        #expect(model.row(last).isDone)
        #expect(!model.row(WorkoutSetID(itemID: item.id, index: 0)).isDone)
        #expect(model.completedSetCount == 1)
    }

    @Test func removingLastDraftPreservesOtherRowsAndDoesNotResurrectDiscardedNumbers() async throws {
        let (model, _, _) = await makeModel(sets: 3, twoExercises: true)
        defer { model.cleanup() }
        model.beginSession()
        let item = model.items[0]
        let first = WorkoutSetID(itemID: item.id, index: 0)
        let middle = WorkoutSetID(itemID: item.id, index: 1)
        let last = WorkoutSetID(itemID: item.id, index: 2)
        let other = WorkoutSetID(itemID: model.items[1].id, index: 0)
        model.enterReps("8", for: first)
        model.toggleSet(first)
        model.enterReps("9", for: middle)
        model.enterWeight("25", for: middle)
        model.enterReps("99", for: last)
        model.enterWeight("99", for: last)
        model.beginNumberEditing(.reps(last))
        model.beginNumberEditing(.weight(last))
        model.enterReps("4", for: other)
        model.removeLastSet()
        #expect(model.currentSetsTotal == 2)
        #expect(model.row(first).isDone && model.row(first).reps == 8)
        #expect(model.row(middle).reps == 9 && model.row(middle).weightKg == 25)
        #expect(model.row(other).reps == 4)
        let added = try #require(model.addSet())
        model.endNumberEditing(.reps(last))
        model.endNumberEditing(.weight(last))
        #expect(added == last)
        #expect(model.row(added).reps == 9 && model.row(added).weightKg == 25)
        #expect(!model.row(added).isDone)
    }

    @Test func invalidLastDraftCanBeRemovedAndTheOnlyRemainingSetIsProtected() async {
        let (model, _, _) = await makeModel()
        defer { model.cleanup() }
        model.beginSession()
        model.enterReps("", for: WorkoutSetID(itemID: model.items[0].id, index: 1))
        #expect(model.hasInvalidNumbers && !model.canAddSet && model.canRemoveLastSet)
        #expect(model.addSet() == nil)
        model.removeLastSet()
        #expect(!model.hasInvalidNumbers && model.currentSetsTotal == 1)
        #expect(!model.canRemoveLastSet)
        model.removeLastSet()
        #expect(model.currentSetsTotal == 1)
    }

    @Test func otherInvalidRowsRemainEditableAfterRemovingTheLastSet() async {
        let (model, _, _) = await makeModel()
        defer { model.cleanup() }
        model.beginSession()
        model.enterWeight("-", for: WorkoutSetID(itemID: model.items[0].id, index: 0))
        model.removeLastSet()
        #expect(model.currentSetsTotal == 1 && model.hasInvalidNumbers)
        #expect(!model.canAddSet && !model.canRemoveLastSet)
        model.enterWeight("10")
        #expect(model.canAddSet)
    }

    @Test(arguments: [false, true])
    func invalidCompletedRowStaysAccessibleWhenRemovingTheLastIncompleteSet(twoExercises: Bool) async {
        let (model, _, sessions) = await makeModel(twoExercises: twoExercises)
        defer { model.cleanup() }
        model.beginSession()
        let itemID = model.items[0].id
        let first = WorkoutSetID(itemID: itemID, index: 0)
        model.toggleSet(first)
        model.enterReps("", for: first)
        model.removeLastSet()
        #expect(model.currentSetsTotal == 1 && model.hasInvalidNumbers)
        #expect(model.viewedItemID == itemID && !model.showsExerciseList)
        model.enterReps("8", for: first)
        #expect(!model.hasInvalidNumbers)
        model.showList()
        #expect(model.showsExerciseList)
        await model.endSession()
        #expect(sessions.savedSessions.first?.items.first?.setReps == [8])
    }

    @Test func setEditsPreserveRestDeadlineAndNotificationUntilTheQueueIsCompleted() async throws {
        let time = ManualWorkoutTimeSource()
        let activity = MockWorkoutLiveActivity()
        let notifications = MockWorkoutRestNotificationClient()
        let alerts = WorkoutRestAlerts(time: time, notifications: notifications, isEnabled: { true })
        let (model, _, sessions) = await makeModel(time: time, activity: activity, alerts: alerts)
        defer { model.cleanup() }
        model.beginSession()
        model.toggleSet(WorkoutSetID(itemID: model.items[0].id, index: 0))
        let deadline = try #require(model.restTimer.deadline)
        let notification = try #require(alerts.notificationID)
        for _ in 0..<100 where notifications.pending[notification] == nil { await Task.yield() }
        time.advance(seconds: 5)
        model.synchronizeRest()
        model.addSet()
        #expect(model.restTimer.deadline == deadline && model.remainingRestSeconds == 40)
        #expect(alerts.notificationID == notification && notifications.pending[notification] == deadline)
        #expect(activity.states.last?.totalSets == 3 && activity.states.last?.setNumber == 2)
        #expect(activity.states.last?.restDeadline == deadline)
        model.removeLastSet()
        #expect(model.restTimer.deadline == deadline && alerts.notificationID == notification)
        #expect(activity.states.last?.totalSets == 2)
        model.removeLastSet()
        #expect(model.allSetsCompleted && model.showsExerciseList)
        #expect(model.currentItemID == nil && !model.isRestActive)
        #expect(alerts.notificationID == nil && notifications.pending.isEmpty)
        #expect(activity.states.last?.allSetsCompleted == true)
        #expect(activity.states.last?.restDeadline == nil)
        model.addSet()
        #expect(!model.allSetsCompleted && !model.showsExerciseList)
        #expect(model.currentItemID == model.items[0].id)
        #expect(activity.states.last?.setNumber == 2 && activity.states.last?.totalSets == 2)
        #expect(activity.states.last?.allSetsCompleted == false)
        #expect(!model.isRestActive && sessions.savedSessions.isEmpty)
    }

    @Test func removalAdvancesCompletedCurrentExerciseWithoutRestartingRest() async {
        let time = ManualWorkoutTimeSource()
        let activity = MockWorkoutLiveActivity()
        let (model, _, _) = await makeModel(twoExercises: true, time: time, activity: activity)
        defer { model.cleanup() }
        model.beginSession()
        model.markSetDone()
        let deadline = model.restTimer.deadline
        model.removeLastSet()
        #expect(model.currentItemID == model.items[1].id && model.viewedItemID == model.items[1].id)
        #expect(model.restTimer.deadline == deadline)
        #expect(activity.states.last?.exerciseName == "B" && activity.states.last?.setNumber == 1)
        model.showExercise(model.items[0].id)
        model.addSet()
        #expect(model.currentItemID == model.items[1].id)
        #expect(model.viewedItemID == model.items[0].id)
        #expect(activity.states.last?.exerciseName == "B")
    }

    @Test(arguments: [false, true])
    func savingEditedSetsPreservesTemplateAndRecordsTheActualSession(smart: Bool) async throws {
        let (model, workouts, sessions) = await makeModel(smart: smart)
        defer { model.cleanup() }
        let original = workouts.stubbedWorkouts[0]
        model.beginSession()
        let itemID = model.items[0].id
        model.enterReps("8", for: WorkoutSetID(itemID: itemID, index: 0))
        model.enterWeight("20", for: WorkoutSetID(itemID: itemID, index: 0))
        model.toggleSet(WorkoutSetID(itemID: itemID, index: 0))
        model.enterReps("9", for: WorkoutSetID(itemID: itemID, index: 1))
        model.enterWeight("25", for: WorkoutSetID(itemID: itemID, index: 1))
        model.toggleSet(WorkoutSetID(itemID: itemID, index: 1))
        let added = try #require(model.addSet())
        model.toggleSet(added)
        model.addSet()
        model.removeLastSet()
        await model.endSession()
        await model.retrySave()
        #expect(sessions.savedSessions.count == 1)
        let saved = try #require(sessions.savedSessions.first?.items.first)
        #expect(saved.plannedSets == 3 && saved.plannedReps == 12)
        #expect(saved.setReps == [8, 9, 9] && saved.setWeightsKg == [20, 25, 25])
        #expect(workouts.stubbedWorkouts[0] == original)
        #expect(workouts.savedWorkouts.isEmpty && workouts.savedVariants.isEmpty)
        let next = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: original.id,
            time: ManualWorkoutTimeSource())
        await next.load()
        #expect(next.currentSetsTotal == 2)
    }

    @Test func largePlansStaySparseAndAddingCannotOverflow() async throws {
        let (model, _, _) = await makeModel(sets: Int.max)
        defer { model.cleanup() }
        model.beginSession()
        #expect(!model.canAddSet && model.addSet() == nil)
        model.removeLastSet()
        #expect(model.currentSetsTotal == Int.max - 1)
        let added = try #require(model.addSet())
        #expect(added.index == Int.max - 1 && model.currentSetsTotal == Int.max)
        #expect(model.completedSets.isEmpty && model.buildSessionItems().first?.setReps.isEmpty == true)
    }
}
