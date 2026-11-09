import SwiftUI

struct SmartMovementCard: View {
    let item: WorkoutItemSnapshot
    let reorderHandle: ExerciseReorderHandle
    let onEdit: () -> Void
    let onReplace: () -> Void

    var body: some View {
        WorkoutMovementCard(name: item.exercise?.displayName ?? String(localized: .uiDesignUnknownExercise),
                            sets: item.sets, reps: item.targetReps, restSeconds: item.restSeconds,
                            repetitionHint: item.exercise?.smartMetadata?.repetitionRule == .total
                                ? nil : item.exercise?.smartMetadata?.repetitionRule.label,
                            reorderHandle: reorderHandle,
                            editIdentifier: "smart.movement.\(item.id)", dragIdentifier: "smart.drag.\(item.id)",
                            replaceIdentifier: "smart.replace.\(item.id)", onEdit: onEdit, onReplace: onReplace)
    }
}
