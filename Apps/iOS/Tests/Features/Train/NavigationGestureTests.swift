import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct NavigationGestureTests {
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
