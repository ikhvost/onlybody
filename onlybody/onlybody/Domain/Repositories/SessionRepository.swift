/// Persistence boundary exposing detached domain values.
@MainActor
protocol SessionRepository: Sendable {
    /// Returns detached history snapshots, newest first.
    func allSessions() async throws -> [SessionSnapshot]
    /// Upserts an entire session by UUID, making retries idempotent.
    func save(_ session: SessionSnapshot) async throws
}
