import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor struct SessionDetailViewModelTests {
    @Test func weightFollowsTheDisplayUnitWithoutChangingSavedResults() {
        let preferences = WorkoutPreferences()
        let item = SessionItemSnapshot(exerciseName: "Press", setReps: [8], setWeightsKg: [50])
        let model = SessionDetailViewModel(session: SessionSnapshot(items: [item]), preferences: preferences)
        #expect(model.weightText(kilograms: 50) == "50 kg")
        preferences.weightUnit = .pounds
        #expect(model.weightText(kilograms: 50).hasSuffix(" lb"))
        #expect(model.session.items.first?.setWeightsKg == [50])
        #expect(model.weightText(kilograms: nil) == "—")
    }
}
