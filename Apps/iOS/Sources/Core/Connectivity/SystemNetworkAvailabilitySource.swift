import Network

/// Cancelling the consuming view task also stops the system path monitor.
struct SystemNetworkAvailabilitySource: NetworkAvailabilitySource {
    func updates() -> AsyncStream<Bool> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let task = Task {
                let monitor = NWPathMonitor()
                defer {
                    monitor.cancel()
                    continuation.finish()
                }
                for await path in monitor {
                    guard !Task.isCancelled else { break }
                    continuation.yield(path.status == .satisfied)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
