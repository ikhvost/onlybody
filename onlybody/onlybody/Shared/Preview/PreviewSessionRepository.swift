#if DEBUG
struct PreviewSessionRepository: SessionRepository {
    let sessions: [SessionSnapshot]

    init(sessions: [SessionSnapshot] = []) {
        self.sessions = sessions
    }

    func allSessions() async throws -> [SessionSnapshot] {
        sessions
    }

    func save(_ session: SessionSnapshot) async throws {}
}
#endif
