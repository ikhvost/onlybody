import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutRestAlertsTests {
    @Test func systemDeliveryAndTimerCannotBothPlayInForeground() async throws {
        let time = ManualWorkoutTimeSource()
        let client = MockWorkoutRestNotificationClient()
        var cues = 0
        let alerts = WorkoutRestAlerts(time: time, notifications: client, isEnabled: { true }, playCue: { cues += 1 })
        let deadline = time.now.addingTimeInterval(30)
        alerts.setDeadline(deadline)
        let id = try #require(alerts.notificationID)
        for _ in 0..<100 where client.pending[id] == nil { await Task.yield() }
        #expect(client.pending[id] == deadline)
        time.advance(seconds: 30)
        alerts.restDidFinish()
        #expect(cues == 0)
        #expect(!alerts.shouldPresentNotification(id: id))
        #expect(!alerts.shouldPresentNotification(id: id))
        alerts.restDidFinish()
        #expect(cues == 1)
    }

    @Test(arguments: [false, true])
    func expiredRestDoesNotReplayOnUnlock(schedulingAllowed: Bool) async {
        let time = ManualWorkoutTimeSource()
        let client = MockWorkoutRestNotificationClient()
        client.allowsScheduling = schedulingAllowed
        var cues = 0
        let alerts = WorkoutRestAlerts(time: time, notifications: client, isEnabled: { true }, playCue: { cues += 1 })
        alerts.setDeadline(time.now.addingTimeInterval(30))
        let id = alerts.notificationID
        for _ in 0..<100 { await Task.yield() }
        time.advance(seconds: 30.5)
        alerts.enterForeground()
        alerts.restDidFinish()
        if let id { #expect(!alerts.shouldPresentNotification(id: id)) }
        #expect(cues == 0)
    }

    @Test func extensionAndSkipCleanUpAnAddAlreadyInFlight() async throws {
        let time = ManualWorkoutTimeSource()
        let client = MockWorkoutRestNotificationClient()
        client.holdsNextSchedule = true
        let alerts = WorkoutRestAlerts(time: time, notifications: client, isEnabled: { true })
        alerts.setDeadline(time.now.addingTimeInterval(30))
        let original = try #require(alerts.notificationID)
        for _ in 0..<100 where client.heldSchedule == nil { await Task.yield() }
        #expect(client.heldSchedule != nil)

        let extended = time.now.addingTimeInterval(45)
        alerts.setDeadline(extended)
        let replacement = try #require(alerts.notificationID)
        for _ in 0..<100 where client.pending[replacement] == nil { await Task.yield() }
        #expect(client.pending == [replacement: extended])
        #expect(!alerts.shouldPresentNotification(id: original))
        alerts.setDeadline(nil)
        client.releaseSchedule()
        for _ in 0..<100 { await Task.yield() }
        #expect(client.pending.isEmpty)
    }

    @Test func permissionRequestIsContextualAndSoundOffSuppressesScheduling() async {
        let client = MockWorkoutRestNotificationClient()
        client.authorization = .notDetermined
        let time = ManualWorkoutTimeSource()
        let muted = WorkoutRestAlerts(time: time, notifications: client, isEnabled: { false })
        muted.prepare()
        muted.setDeadline(time.now.addingTimeInterval(30))
        #expect(muted.notificationID == nil)
        #expect(client.permissionRequests == 0)

        let audible = WorkoutRestAlerts(time: time, notifications: client, isEnabled: { true })
        audible.prepare()
        for _ in 0..<100 where client.permissionRequests == 0 { await Task.yield() }
        #expect(client.permissionRequests == 1)
    }
}
