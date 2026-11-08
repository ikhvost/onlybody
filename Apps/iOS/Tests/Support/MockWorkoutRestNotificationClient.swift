import Foundation
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
final class MockWorkoutRestNotificationClient: WorkoutRestNotificationClient {
    var authorization: ReminderAuthorization = .authorized
    var permissionRequests = 0
    var allowsScheduling = true
    var holdsNextSchedule = false
    private(set) var pending: [String: Date] = [:]
    private(set) var heldSchedule: CheckedContinuation<Void, Never>?

    func restAlertAuthorization() async -> ReminderAuthorization { authorization }

    func requestAuthorization() async throws -> Bool {
        permissionRequests += 1
        authorization = .authorized
        return true
    }

    func scheduleRestAlert(id: String, deadline: Date) async throws -> Bool {
        if holdsNextSchedule {
            holdsNextSchedule = false
            await withCheckedContinuation { heldSchedule = $0 }
        }
        guard allowsScheduling else { return false }
        pending[id] = deadline
        return true
    }

    func removeRestAlert(id: String) {
        pending.removeValue(forKey: id)
    }

    func releaseSchedule() {
        heldSchedule?.resume()
        heldSchedule = nil
    }
}
