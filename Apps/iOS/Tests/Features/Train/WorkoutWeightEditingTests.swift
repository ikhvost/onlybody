import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct WorkoutWeightEditingTests {
    private func model(unit: WeightUnit = .kilograms, started: Bool = true,
                       historyWeightKg: Double? = nil) async -> ActiveWorkoutViewModel {
        let workouts = MockWorkoutRepository()
        let workout = WorkoutSnapshot(items: [WorkoutItemSnapshot(sets: 2, exercise: ExerciseSnapshot(name: "Fixture"))])
        workouts.stubbedWorkouts = [workout]
        let sessions = MockSessionRepository()
        if let historyWeightKg {
            sessions.stubbedSessions = [SessionSnapshot(items: [
                SessionItemSnapshot(exerciseName: "Fixture", setReps: [12, 12], weightKg: historyWeightKg)
            ])]
        }
        let model = ActiveWorkoutViewModel(workouts: workouts, sessions: sessions, workoutId: workout.id,
                                           time: ManualWorkoutTimeSource(), preferences: WorkoutPreferences(weightUnit: unit),
                                           alwaysShowsWeight: true)
        await model.load()
        if started { model.beginSession() }
        return model
    }

    @Test(arguments: WeightUnit.allCases)
    func zeroAndNonzeroWeightAreClearedOnceAndNewValuesAreApplied(unit: WeightUnit) async {
        let vm = await model(unit: unit)
        defer { vm.cleanup() }
        let key = vm.currentKey
        vm.beginNumberEditing(.weight(key))
        #expect(vm.weightText(for: key).isEmpty)
        #expect(vm.row(key).weightKg == 0)
        #expect(!vm.hasInvalidNumbers)
        vm.enterWeight("50", for: key)
        vm.beginNumberEditing(.weight(key))
        #expect(vm.weightText(for: key) == "50")
        vm.endNumberEditing(.weight(key))
        #expect(vm.row(key).weightKg == unit.kilograms(from: 50))
        vm.beginNumberEditing(.weight(key))
        #expect(vm.weightText(for: key).isEmpty)
        vm.endNumberEditing(.weight(key))
        vm.endNumberEditing(.weight(key))
        #expect(vm.weightText(for: key) == "50")
    }

    @Test func closingUntouchedZeroPreservesCompletionAndRest() async {
        let vm = await model()
        defer { vm.cleanup() }
        let key = vm.currentKey
        vm.toggleSet(key)
        let remaining = vm.remainingRestSeconds
        vm.beginNumberEditing(.weight(key))
        vm.enterWeight("", for: key) // SwiftUI can echo the programmatic clearing.
        vm.endNumberEditing(.weight(key))
        #expect(vm.weightText(for: key) == "0")
        #expect(vm.row(key).isDone)
        #expect(vm.completedSetCount == 1)
        #expect(vm.remainingRestSeconds == remaining)
        #expect(!vm.hasInvalidNumbers)
    }

    @Test(arguments: WeightUnit.allCases)
    func erasingReplacementRestoresExactOriginalKilograms(unit: WeightUnit) async {
        let vm = await model(unit: unit)
        defer { vm.cleanup() }
        let key = vm.currentKey
        vm.enterWeight("23,45", for: key, locale: Locale(identifier: "uk_UA"))
        let original = vm.row(key).weightKg
        vm.beginNumberEditing(.weight(key))
        vm.enterWeight("8,25", for: key, locale: Locale(identifier: "uk_UA"))
        #expect(vm.row(key).weightKg == unit.kilograms(from: 8.25))
        vm.enterWeight("", for: key)
        #expect(!vm.hasInvalidNumbers)
        #expect(vm.row(key).weightKg == original)
        vm.endNumberEditing(.weight(key))
        #expect(vm.row(key).weightKg == original)
        #expect(vm.weightText(for: key) == "23.45" || vm.weightText(for: key) == "23,45")
    }

    @Test(arguments: [false, true])
    func repetitionsReplaceAndRestoreBeforeAndAfterStarting(started: Bool) async {
        let vm = await model(started: started)
        defer { vm.cleanup() }
        let key = vm.currentKey
        vm.beginNumberEditing(.reps(key))
        #expect(vm.repsText(for: key).isEmpty)
        #expect(vm.row(key).reps == 12)
        #expect(!vm.hasInvalidNumbers)
        vm.endNumberEditing(.reps(key))
        #expect(vm.repsText(for: key) == "12")
        vm.beginNumberEditing(.reps(key))
        vm.enterReps("8", for: key)
        vm.beginNumberEditing(.reps(key))
        #expect(vm.repsText(for: key) == "8")
        vm.enterReps("", for: key)
        #expect(!vm.hasInvalidNumbers)
        #expect(vm.row(key).reps == 12)
        vm.endNumberEditing(.reps(key))
        vm.endNumberEditing(.reps(key))
        #expect(vm.repsText(for: key) == "12")
        vm.enterReps("0", for: key)
        vm.beginNumberEditing(.reps(key))
        #expect(vm.repsText(for: key).isEmpty)
        vm.enterReps("7", for: key)
        vm.endNumberEditing(.reps(key))
        #expect(vm.row(key).reps == 7)
    }

    @Test(arguments: WeightUnit.allCases)
    func restoringHistoryWeightDoesNotRoundThroughTheDisplayedUnit(unit: WeightUnit) async {
        let original = 18.123456789
        let vm = await model(unit: unit, historyWeightKg: original)
        defer { vm.cleanup() }
        let key = vm.currentKey
        let displayed = vm.weightText(for: key)
        vm.beginNumberEditing(.weight(key))
        vm.enterWeight("8", for: key)
        vm.enterWeight("", for: key)
        vm.endNumberEditing(.weight(key))
        #expect(vm.row(key).weightKg == original)
        #expect(vm.weightText(for: key) == displayed)
        vm.toggleSet(key)
        #expect(vm.buildSessionItems().first?.setWeightsKg == [original])
    }

    @Test func fieldsAndRowsRetainIndependentOriginalsAndCompletionFinalizesInput() async {
        let vm = await model()
        defer { vm.cleanup() }
        let first = vm.currentKey
        let second = WorkoutSetID(itemID: first.itemID, index: 1)
        vm.enterWeight("25", for: first)
        vm.beginNumberEditing(.reps(first))
        vm.beginNumberEditing(.weight(first))
        vm.beginNumberEditing(.reps(second))
        vm.enterReps("6", for: second)
        vm.endNumberEditing(.reps(first))
        #expect(vm.repsText(for: first) == "12")
        #expect(vm.weightText(for: first).isEmpty)
        #expect(vm.repsText(for: second) == "6")
        vm.toggleSet(first)
        #expect(vm.row(first).isDone)
        #expect(vm.weightText(for: first) == "25")
        #expect(vm.row(second).reps == 6)
        #expect(!vm.hasInvalidNumbers)
    }

    @Test func nonemptyErrorsSurviveBlurAndRefocusUntilCorrected() async {
        let vm = await model()
        defer { vm.cleanup() }
        let key = vm.currentKey
        vm.beginNumberEditing(.weight(key))
        vm.enterWeight("1.234", for: key, locale: Locale(identifier: "en_US"))
        vm.endNumberEditing(.weight(key))
        vm.beginNumberEditing(.weight(key))
        #expect(vm.weightText(for: key) == "1.234")
        vm.beginNumberEditing(.reps(key))
        vm.enterReps("-1", for: key)
        vm.endNumberEditing(.reps(key))
        vm.beginNumberEditing(.reps(key))
        #expect(vm.repsText(for: key) == "-1")
        vm.toggleSet(key)
        #expect(!vm.row(key).isDone)
        #expect(vm.hasInvalidNumbers)
        vm.beginNumberEditing(.reps(key))
        vm.enterReps("", for: key)
        vm.endNumberEditing(.reps(key))
        vm.beginNumberEditing(.weight(key))
        vm.enterWeight("", for: key)
        vm.endNumberEditing(.weight(key))
        #expect(!vm.hasInvalidNumbers)
        #expect(vm.row(key).reps == 12)
        #expect(vm.row(key).weightKg == 0)
    }

    @Test func leavingOrReplacingExerciseDoesNotRestoreStaleInput() async throws {
        let vm = await model(started: false)
        defer { vm.cleanup() }
        let key = vm.currentKey
        vm.beginNumberEditing(.reps(key))
        vm.showList()
        #expect(vm.repsText(for: key) == "12")
        vm.beginNumberEditing(.reps(key))
        vm.enterReps("5", for: key)
        vm.replaceExercise(key.itemID, with: ExerciseSnapshot(name: "Replacement"))
        vm.endNumberEditing(.reps(key))
        #expect(vm.repsText(for: key) == "12")
    }
}
