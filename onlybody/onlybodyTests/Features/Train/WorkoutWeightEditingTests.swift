import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutWeightEditingTests {
    private func model(unit: WeightUnit = .kilograms) async -> ActiveWorkoutViewModel {
        let workouts = MockWorkoutRepository()
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot(sets: 2)])
        workouts.stubbedWorkouts = [workout]
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: MockSessionRepository(), workoutId: workout.id,
                                           time: ManualWorkoutTimeSource(), preferences: WorkoutPreferences(weightUnit: unit),
                                           alwaysShowsWeight: true)
        await model.load()
        model.beginSession()
        return model
    }

    @Test(arguments: WeightUnit.allCases)
    func zeroIsReplacedAndNonzeroIsPreservedOnFocus(unit: WeightUnit) async {
        let vm = await model(unit: unit)
        defer { vm.cleanup() }
        let key = vm.currentKey
        vm.beginWeightEditing(key)
        #expect(vm.weightText(for: key).isEmpty)
        #expect(vm.row(key).weightKg == 0)
        #expect(!vm.hasInvalidNumbers)
        vm.enterWeight("50", for: key)
        vm.endWeightEditing(key)
        #expect(vm.weightText(for: key) == "50")
        #expect(vm.row(key).weightKg == unit.kilograms(from: 50))
        vm.beginWeightEditing(key)
        #expect(vm.weightText(for: key) == "50")
    }

    @Test func closingUntouchedZeroRestoresDisplayWithoutChangingCompletionOrRest() async {
        let vm = await model()
        defer { vm.cleanup() }
        let key = vm.currentKey
        vm.toggleSet(key)
        let remaining = vm.remainingRestSeconds
        vm.beginWeightEditing(key)
        vm.enterWeight("", for: key) // SwiftUI echoes the initial clearing.
        vm.endWeightEditing(key)
        #expect(vm.weightText(for: key) == "0")
        #expect(vm.row(key).isDone)
        #expect(vm.completedSetCount == 1)
        #expect(vm.remainingRestSeconds == remaining)
        #expect(!vm.hasInvalidNumbers)
    }

    @Test func clearingAnEnteredValueDoesNotSilentlyRestoreZero() async {
        let vm = await model()
        defer { vm.cleanup() }
        let key = vm.currentKey
        vm.enterWeight("50", for: key)
        vm.enterWeight("", for: key)
        vm.endWeightEditing(key)
        #expect(vm.hasInvalidNumbers)
        #expect(vm.weightText(for: key).isEmpty)
        #expect(vm.row(key).weightKg == 50)
        vm.beginWeightEditing(key)
        #expect(vm.hasInvalidNumbers)
        vm.enterWeight("0", for: key)
        vm.beginWeightEditing(key)
        vm.endWeightEditing(key)
        #expect(vm.weightText(for: key) == "0")
        #expect(!vm.hasInvalidNumbers)
    }
}
