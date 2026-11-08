import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutLiveActivityTests {
    @Test func publishesWorkoutQueueAndSharedRestDeadlineUntilSessionEnds() async throws {
        let first = WorkoutItemSnapshot(order: 0, sets: 2, restSeconds: 30, exercise: ExerciseSnapshot(name: "Test movement A"))
        let second = WorkoutItemSnapshot(order: 1, sets: 1, restSeconds: 30, exercise: ExerciseSnapshot(name: "Test movement B"))
        let workout = WorkoutSnapshot(name: "Evening", items: [first, second])
        let workouts = MockWorkoutRepository()
        workouts.stubbedWorkouts = [workout]
        let time = ManualWorkoutTimeSource()
        let liveActivity = MockWorkoutLiveActivity()
        let notifications = MockWorkoutRestNotificationClient()
        let alerts = WorkoutRestAlerts(time: time, notifications: notifications, isEnabled: { true })
        let model = ActiveWorkoutViewModel(
            workouts: workouts, sessions: MockSessionRepository(), workoutId: workout.id,
            time: time, restAlerts: alerts, liveActivity: liveActivity
        )
        await model.load()
        #expect(liveActivity.states.isEmpty)
        model.beginSession()
        #expect(liveActivity.workoutName == "Evening")
        #expect(liveActivity.states.last?.setNumber == 1)

        model.showExercise(second.id)
        #expect(liveActivity.states.last?.exerciseName == "Test movement A")
        let firstSet = WorkoutSetID(itemID: first.id, index: 0)
        model.toggleSet(firstSet)
        #expect(liveActivity.states.last?.setNumber == 2)
        #expect(liveActivity.states.last?.restDeadline == time.now.addingTimeInterval(30))
        model.extendRest()
        let alertID = try #require(alerts.notificationID)
        for _ in 0..<100 where notifications.pending[alertID] == nil { await Task.yield() }
        #expect(notifications.pending[alertID] == time.now.addingTimeInterval(45))
        #expect(liveActivity.states.last?.restDeadline == notifications.pending[alertID])

        model.toggleSet(firstSet)
        #expect(liveActivity.states.last?.restDeadline == nil)
        #expect(notifications.pending.isEmpty)
        model.toggleSet(firstSet)
        model.toggleSet(WorkoutSetID(itemID: first.id, index: 1))
        #expect(liveActivity.states.last?.exerciseName == "Test movement B")
        model.toggleSet(WorkoutSetID(itemID: second.id, index: 0))
        #expect(liveActivity.states.last?.allSetsCompleted == true)
        #expect(!model.isRestActive)
        #expect(alerts.notificationID == nil)
        #expect(!liveActivity.hasEnded)
        await model.endSession()
        #expect(liveActivity.hasEnded)
    }
}
