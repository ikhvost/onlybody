import Foundation
import SwiftData
import Testing
@testable import onlybody

@MainActor
struct SwiftDataSessionRepositoryTests {
    @Test
    func saveAndFetchSessions() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Session.self,
            SessionItem.self,
            configurations: configuration
        )
        let repository = SwiftDataSessionRepository(context: container.mainContext)

        var session1 = SessionSnapshot()
        session1.workoutName = "Full Body"
        session1.durationSeconds = 1450

        session1.date = Date(timeIntervalSince1970: 1_000_000)

        var session2 = SessionSnapshot()
        session2.workoutName = "Upper Body"
        session2.durationSeconds = 2178

        session2.date = Date(timeIntervalSince1970: 2_000_000)

        try await repository.save(session1)
        try await repository.save(session2)

        let all = try await repository.allSessions()
        #expect(all.count == 2)
        #expect(all.map(\.workoutName) == ["Upper Body", "Full Body"])
        #expect(all.first?.durationSeconds == 2178)
    }

    @Test
    func saveSessionWithItems() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Session.self,
            SessionItem.self,
            configurations: configuration
        )
        let repository = SwiftDataSessionRepository(context: container.mainContext)

        var item1 = SessionItemSnapshot()
        item1.order = 0
        item1.exerciseName = "Push-Ups"
        item1.plannedSets = 3
        item1.plannedReps = 12
        item1.setReps = [12, 12, 10]

        var item2 = SessionItemSnapshot()
        item2.order = 1
        item2.exerciseName = "Squats"
        item2.plannedSets = 4
        item2.plannedReps = 15
        item2.setReps = [15, 15, 15, 15]
        item2.weightKg = 10.0
        item2.setWeightsKg = [0, 2.5, 5, 10]

        var session = SessionSnapshot()
        session.workoutName = "Full Body"
        session.items = [item1, item2]

        try await repository.save(session)

        let all = try await repository.allSessions()
        #expect(all.count == 1)

        let fetched = all[0]
        #expect(fetched.workoutName == "Full Body")
        #expect(fetched.items.count == 2)

        let sorted = fetched.items.sorted { $0.order < $1.order }
        #expect(sorted[0].exerciseName == "Push-Ups")
        #expect(sorted[0].setReps == [12, 12, 10])
        #expect(sorted[1].exerciseName == "Squats")
        #expect(sorted[1].weightKg == 10.0)
        #expect(sorted[1].setWeightsKg == [0, 2.5, 5, 10])
    }

    @Test
    func updateSession() async throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Session.self,
            SessionItem.self,
            configurations: configuration
        )
        let repository = SwiftDataSessionRepository(context: container.mainContext)

        var session = SessionSnapshot()
        session.workoutName = "Original"
        session.durationSeconds = 0
        try await repository.save(session)

        session.workoutName = "Updated"
        session.durationSeconds = 1800

        try await repository.save(session)

        let all = try await repository.allSessions()
        #expect(all.count == 1)
        #expect(all[0].workoutName == "Updated")
        #expect(all[0].durationSeconds == 1800)

    }
}
