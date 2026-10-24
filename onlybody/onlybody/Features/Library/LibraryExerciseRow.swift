import SwiftUI

struct LibraryExerciseRow: View {
    let exercise: ExerciseSnapshot
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.space10) {
                VStack(alignment: .leading, spacing: Theme.space2) {
                    Text(exercise.name)
                        .font(Theme.fontSans(Theme.type16, .bold))
                        .foregroundStyle(Theme.text)

                    MonoLabel(
                        text: "\(exercise.primaryMuscle) · \(exercise.equipmentLabel)",
                        size: Theme.type10,
                        color: Theme.text3,
                        tracking: 0.3
                    )
                    ExerciseDifficultyBadge(difficulty: exercise.difficulty)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ChevronIcon(color: Theme.text3, size: Theme.type14)
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.vertical, Theme.space13)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("library.exercise.\(exercise.name)")
    }
}
