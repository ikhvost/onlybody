import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct NavigationGestureTests {
    @Test func tabOrderDoesNotWrap() {
        #expect(AppTab.train.adjacent(forward: false) == nil)
        #expect(AppTab.train.adjacent(forward: true) == .log)
        #expect(AppTab.log.adjacent(forward: true) == .library)
        #expect(AppTab.log.adjacent(forward: false) == .train)
        #expect(AppTab.library.adjacent(forward: false) == .log)
        #expect(AppTab.library.adjacent(forward: true) == nil)
    }

    @Test func failedSaveRetainsDirtyDraftAndSuccessfulSaveClearsIt() async {
        let repo = MockWorkoutRepository()
        let vm = SessionBuilderViewModel(workouts: repo, exercises: MockExerciseRepository())
        vm.name = "Draft"
        repo.shouldThrow = true
        #expect(await vm.save() == false)
        #expect(vm.hasUnsavedChanges)
        #expect(vm.name == "Draft")
        repo.shouldThrow = false
        #expect(await vm.save())
        #expect(!vm.hasUnsavedChanges)
    }

    @Test func swipeThresholdsRejectVerticalShortAndReversedGestures() {
        let limits = Theme.tabSwipeThresholds
        #expect(TabSwipeDecision.accepts(horizontal: -90, vertical: 10, velocity: -100, thresholds: limits))
        #expect(TabSwipeDecision.accepts(horizontal: 25, vertical: 5, velocity: 600, thresholds: limits))
        #expect(!TabSwipeDecision.accepts(horizontal: 15, vertical: 0, velocity: 900, thresholds: limits))
        #expect(!TabSwipeDecision.accepts(horizontal: 90, vertical: 80, velocity: 900, thresholds: limits))
        #expect(!TabSwipeDecision.accepts(horizontal: 25, vertical: 0, velocity: -600, thresholds: limits))
    }

    @Test func draftChangesAndRestorationAreDetectedWithoutCatalogLoading() async {
        let vm = SessionBuilderViewModel(workouts: MockWorkoutRepository(), exercises: MockExerciseRepository())
        #expect(!vm.hasUnsavedChanges)
        await vm.loadExercises()
        #expect(!vm.hasUnsavedChanges)
        vm.name = "Changed"
        #expect(vm.hasUnsavedChanges)
        vm.name = ""
        #expect(!vm.hasUnsavedChanges)
        vm.toggleDay("Mon")
        #expect(vm.hasUnsavedChanges)
        vm.toggleDay("Mon")
        #expect(!vm.hasUnsavedChanges)
        vm.addMovement(ExerciseSnapshot(name: "Squats"))
        #expect(vm.hasUnsavedChanges)
        vm.movements = []
        #expect(!vm.hasUnsavedChanges)
    }
}
