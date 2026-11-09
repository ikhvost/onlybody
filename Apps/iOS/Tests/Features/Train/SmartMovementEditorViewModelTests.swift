import Foundation
import Testing
#if ONLYWEIGHTS
@testable import onlyweights
#else
@testable import onlybody
#endif

@MainActor
struct SmartMovementEditorViewModelTests {
    @Test func draftIsDetachedAndInvalidInputCannotReplaceCommittedNumbers() {
        let original = WorkoutItemSnapshot(sets: 3, targetReps: 10, restSeconds: 90)
        let model = SmartMovementEditorViewModel(item: original)
        model.enter("4", field: "Sets")
        model.enter("", field: "Reps")
        #expect(model.hasInvalidNumbers)
        #expect(model.text("Reps").isEmpty)
        #expect(model.item.targetReps == 10)
        #expect(original.sets == 3)
        #expect(model.item.sets == 4)
        model.enter("12", field: "Reps")
        #expect(!model.hasInvalidNumbers)
        #expect(model.item.targetReps == 12)
    }

    @Test func steppingAndValidationRespectNumericBoundaries() {
        let model = SmartMovementEditorViewModel(item: WorkoutItemSnapshot(sets: 1, restSeconds: 0))
        #expect(!model.canDecrease("Sets"))
        #expect(!model.canDecrease("Rest"))
        model.step("Rest", increasing: true)
        #expect(model.item.restSeconds == 15)
        model.enter("2147483647", field: "Sets")
        model.step("Sets", increasing: true)
        #expect(model.item.sets == Int(Int32.max))
        for value in ["-1", "0", "1.5", "2147483648"] {
            model.enter(value, field: "Sets")
            #expect(model.hasError("Sets"))
            #expect(model.item.sets == Int(Int32.max))
        }
    }
}
