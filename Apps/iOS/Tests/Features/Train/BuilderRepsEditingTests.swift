import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct BuilderRepsEditingTests {
    private func model(mode: WorkoutMode = .manual) -> SessionBuilderViewModel {
        let exercise = ExerciseSnapshot(name: "Fixture")
        let workout = WorkoutSnapshot(mode: mode.rawValue, items: [WorkoutItemSnapshot(exercise: exercise)])
        return SessionBuilderViewModel(workouts: MockWorkoutRepository(), exercises: MockExerciseRepository(), workout: workout)
    }

    @Test(arguments: [WorkoutMode.manual, .smart])
    func focusAndEmptyReplacementPreservePrescriptionAndDirtyState(mode: WorkoutMode) throws {
        let vm = model(mode: mode)
        let movement = try #require(vm.movements.first)
        let duration = vm.estimatedDurationSeconds
        vm.beginRepsEditing(movement.id)
        #expect(vm.numberText("Reps", movement: movement).isEmpty)
        #expect(vm.canSave)
        #expect(!vm.hasUnsavedChanges)
        #expect(vm.estimatedDurationSeconds == duration)
        vm.endRepsEditing(movement.id)
        #expect(vm.numberText("Reps", movement: movement) == "12")
        vm.beginRepsEditing(movement.id)
        vm.enterNumber("8", field: "Reps", id: movement.id)
        vm.beginRepsEditing(movement.id)
        #expect(vm.numberText("Reps", movement: movement) == "8")
        #expect(vm.hasUnsavedChanges)
        vm.enterNumber("", field: "Reps", id: movement.id)
        #expect(!vm.hasUnsavedChanges)
        #expect(vm.canSave)
        #expect(vm.estimatedDurationSeconds == duration)
        vm.endRepsEditing(movement.id)
        vm.endRepsEditing(movement.id)
        #expect(vm.numberText("Reps", movement: movement) == "12")
    }

    @Test func emptyFocusDoesNotBlockStepOrSaveAndNewValuePersists() async throws {
        let repo = MockWorkoutRepository()
        let vm = SessionBuilderViewModel(workouts: repo, exercises: MockExerciseRepository())
        vm.addMovement(ExerciseSnapshot(name: "Fixture"))
        let movement = try #require(vm.movements.first)
        vm.beginRepsEditing(movement.id)
        vm.stepNumber("Reps", id: movement.id, increasing: true)
        vm.endRepsEditing(movement.id)
        #expect(vm.movements.first?.reps == 13)
        vm.beginRepsEditing(movement.id)
        #expect(await vm.save())
        #expect(repo.savedWorkouts.last?.items.first?.targetReps == 13)
        vm.beginRepsEditing(movement.id)
        vm.enterNumber("8", field: "Reps", id: movement.id)
        #expect(await vm.save())
        #expect(repo.savedWorkouts.last?.items.first?.targetReps == 8)
    }

    @Test func errorsArePreservedAndOtherNumericFieldsKeepTheirValidation() throws {
        let vm = model()
        let movement = try #require(vm.movements.first)
        vm.beginRepsEditing(movement.id)
        vm.enterNumber("0", field: "Reps", id: movement.id)
        vm.endRepsEditing(movement.id)
        vm.beginRepsEditing(movement.id)
        #expect(vm.numberText("Reps", movement: movement) == "0")
        #expect(!vm.canSave)
        vm.enterNumber("", field: "Reps", id: movement.id)
        vm.endRepsEditing(movement.id)
        #expect(vm.canSave)
        for field in ["Sets", "Rest"] {
            vm.enterNumber("", field: field, id: movement.id)
            #expect(vm.numberHasError(field, id: movement.id))
        }
    }

    @Test func cancellingRemovingAndReplacingClearEditingOriginals() throws {
        let vm = model()
        let original = try #require(vm.movements.first)
        vm.beginRepsEditing(original.id)
        vm.enterNumber("8", field: "Reps", id: original.id)
        vm.restoreMovement(original)
        vm.endRepsEditing(original.id)
        #expect(vm.movements.first?.reps == original.reps)
        #expect(vm.movements.first?.exercise == original.exercise)
        #expect(!vm.hasUnsavedChanges)
        vm.beginRepsEditing(original.id)
        vm.replaceMovement(original.id, with: ExerciseSnapshot(name: "Replacement"))
        vm.endRepsEditing(original.id)
        #expect(vm.movements.first?.reps == original.reps)
        vm.beginRepsEditing(original.id)
        vm.removeMovement(original.id)
        vm.endRepsEditing(original.id)
        vm.enterNumber("", field: "Reps", id: original.id)
        #expect(vm.numberInputs.isEmpty)
        #expect(!vm.hasInvalidNumbers)
    }

    @Test func separateMovementsDoNotShareOriginalRepetitions() throws {
        let vm = model()
        let first = try #require(vm.movements.first)
        vm.addMovement(ExerciseSnapshot(name: "Second"))
        let second = try #require(vm.movements.last)
        vm.setReps(20, forMovement: second.id)
        vm.beginRepsEditing(first.id)
        vm.beginRepsEditing(second.id)
        vm.enterNumber("5", field: "Reps", id: first.id)
        vm.endRepsEditing(second.id)
        vm.endRepsEditing(first.id)
        #expect(vm.movements.first?.reps == 5)
        #expect(vm.movements.last?.reps == 20)
    }
}
