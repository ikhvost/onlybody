#if DEBUG
struct PreviewSessionRepository: SessionRepository {
    let sessions: [Session]

    init(sessions: [Session] = []) {
        self.sessions = sessions
    }

    func allSessions() async throws -> [Session] {
        sessions
    }

    func save(_ session: Session) async throws {}
}
#endif
