import SwiftUI

/// Shared editing affordances for manually assembled and generated workouts.
struct WorkoutMovementCard: View {
    let name: String
    let sets: Int
    let reps: Int
    let restSeconds: Int
    var repetitionHint: String?
    let reorderHandle: ExerciseReorderHandle
    let editIdentifier: String
    let dragIdentifier: String
    let replaceIdentifier: String
    let onEdit: () -> Void
    let onReplace: () -> Void

    var body: some View {
        HStack(spacing: Theme.space8) {
            reorderHandle.accessibilityIdentifier(dragIdentifier)
            Button(action: onEdit) {
                VStack(alignment: .leading, spacing: Theme.space8) {
                    Text(name).font(Theme.fontSans(Theme.typeBody, .semibold)).foregroundStyle(Theme.text)
                    Text(.uiMovementSummary(sets, reps, restSeconds))
                        .font(Theme.fontSans(Theme.type13)).foregroundStyle(Theme.text2)
                    if let repetitionHint {
                        Text(repetitionHint).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                    }
                }.frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
            }.accessibilityIdentifier(editIdentifier)
            ExerciseReplaceButton(identifier: replaceIdentifier, onReplace: onReplace)
        }
        .padding(Theme.cardInset).background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .buttonStyle(PressableButtonStyle(animates: false))
    }
}
