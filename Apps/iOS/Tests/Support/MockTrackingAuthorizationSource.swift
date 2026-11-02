#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
final class MockTrackingAuthorizationSource: TrackingAuthorizationSource {
    var status: TrackingPermission
    var response: TrackingPermission = .authorized
    var waitsForResponse = false
    private(set) var requestCount = 0
    private(set) var continuation: CheckedContinuation<TrackingPermission, Never>?

    init(status: TrackingPermission = .authorized) { self.status = status }

    func request() async -> TrackingPermission {
        requestCount += 1
        if waitsForResponse {
            return await withCheckedContinuation { continuation = $0 }
        }
        if status == .notDetermined { status = response }
        return status
    }

    func resolve(_ permission: TrackingPermission) {
        status = permission
        continuation?.resume(returning: permission)
        continuation = nil
    }
}
