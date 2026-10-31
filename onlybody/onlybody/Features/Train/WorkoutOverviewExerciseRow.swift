import SwiftUI

struct WorkoutOverviewExerciseRow: View {
    let item: WorkoutItemSnapshot
    let onExercise: (ExerciseSnapshot) -> Void

    var body: some View {
        Button { if let exercise = item.exercise { onExercise(exercise) } } label: {
            VStack(alignment: .leading, spacing: Theme.space8) {
                Text(item.exercise?.displayName ?? String(localized: .uiDesignUnknownExercise))
                    .font(Theme.fontSans(Theme.typeCard, .semibold)).foregroundStyle(Theme.text)
                Text(String(localized: .uiMovementSummary(item.sets, item.targetReps, item.restSeconds)))
                    .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                if let exercise = item.exercise {
                    Text(exercise.primaryMuscleLabel).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                }
            }
            .frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
            .padding(Theme.cardInset).background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(PressableButtonStyle(animates: false)).disabled(item.exercise == nil)
        .accessibilityIdentifier("overview.exercise.\(item.id)")
    }
}
