/// Emits connectivity changes for the lifetime of a screen task.
@MainActor
protocol NetworkAvailabilitySource {
    func updates() -> AsyncStream<Bool>
}
