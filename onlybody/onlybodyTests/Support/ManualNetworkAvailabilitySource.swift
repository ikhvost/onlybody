@testable import onlybody

@MainActor
final class ManualNetworkAvailabilitySource: NetworkAvailabilitySource {
    private(set) var continuation: AsyncStream<Bool>.Continuation?

    func updates() -> AsyncStream<Bool> {
        AsyncStream { continuation = $0 }
    }
}
