struct EmptySessionRepository: SessionRepository {
    func allSessions() async throws -> [Session] { [] }
    func save(_ session: Session) async throws {}
}
