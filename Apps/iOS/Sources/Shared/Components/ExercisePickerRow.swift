import SwiftUI

/// The guide and add action are separate hit targets; the row has no disclosure arrow.
struct ExercisePickerRow: View {
    let exercise: ExerciseSnapshot
    let onGuide: () -> Void
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: Theme.space12) {
            Button(action: onGuide) {
                VStack(alignment: .leading, spacing: Theme.space4) {
                    Text(exercise.displayName).font(Theme.fontSans(Theme.typeBody, .semibold)).foregroundStyle(Theme.text)
                    Text("\(exercise.primaryMuscleLabel) · \(exercise.equipmentLabel)")
                        .font(Theme.fontSans(Theme.type13)).foregroundStyle(Theme.text2)
                }
                .frame(maxWidth: .infinity, minHeight: Theme.touchSize, alignment: .leading)
                .contentShape(.rect)
            }
            .accessibilityIdentifier("exercise.guide.\(exercise.name)")
            Button(action: onAdd) {
                PlusIcon(color: Theme.accent)
                    .frame(width: Theme.touchSize, height: Theme.touchSize)
                    .background(Theme.accentDim, in: .circle)
            }
            .accessibilityLabel(String(localized: .uiAdd) + " " + exercise.displayName)
            .accessibilityIdentifier("exercise.pick.\(exercise.name)")
        }
        .padding(.horizontal, Theme.horizontalPadding).padding(.vertical, Theme.space8)
        .buttonStyle(PressableButtonStyle(animates: false))
    }
}
