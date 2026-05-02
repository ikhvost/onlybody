protocol SessionRepository: Sendable {
    func allSessions() async throws -> [Session]
    func recentSessions(limit: Int) async throws -> [Session]
    func save(_ session: Session) async throws
}
