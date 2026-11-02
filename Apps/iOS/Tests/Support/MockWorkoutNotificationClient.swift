import Foundation
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
final class MockWorkoutNotificationClient: WorkoutNotificationClient {
    var status: ReminderAuthorization = .authorized
    var grantsPermission = true
    var requestShouldThrow = false
    var failOnAdd: Int?
    var suspendNextAdd = false
    var suspendPermissionRequest = false
    private(set) var authorizationRequests = 0
    private(set) var removals = 0
    private(set) var additions = 0
    private(set) var pending: [String: WorkoutReminderRequest] = [:]
    private var addContinuation: CheckedContinuation<Void, Never>?
    private var permissionContinuation: CheckedContinuation<Void, Never>?
    var isWaitingForAdd: Bool { addContinuation != nil }
    var isWaitingForPermission: Bool { permissionContinuation != nil }

    func authorizationStatus() async -> ReminderAuthorization { status }

    func requestAuthorization() async throws -> Bool {
        authorizationRequests += 1
        if suspendPermissionRequest {
            await withCheckedContinuation { permissionContinuation = $0 }
        }
        if requestShouldThrow { throw TestError.expectedFailure }
        status = grantsPermission ? .authorized : .denied
        return grantsPermission
    }

    func removePendingReminders() async {
        removals += 1
        pending.removeAll()
    }

    func add(_ request: WorkoutReminderRequest) async throws {
        additions += 1
        if suspendNextAdd {
            suspendNextAdd = false
            await withCheckedContinuation { addContinuation = $0 }
        }
        if additions == failOnAdd { throw TestError.expectedFailure }
        pending[request.identifier] = request
    }

    func resumeAdd() {
        addContinuation?.resume()
        addContinuation = nil
    }

    func resumePermission() {
        permissionContinuation?.resume()
        permissionContinuation = nil
    }
}
