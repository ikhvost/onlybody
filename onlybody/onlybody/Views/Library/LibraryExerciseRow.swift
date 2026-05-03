import SwiftUI

struct LibraryExerciseRow: View {
    let exercise: Exercise
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(Theme.fontSans(15, .bold))
                        .foregroundStyle(Theme.text)

                    MonoLabel(
                        text: "\(exercise.primaryMuscle) · \(exercise.equipmentLabel)",
                        size: 9,
                        color: Theme.text3,
                        tracking: 0.3
                    )

                    if exercise.isCustom {
                        CustomBadgeView()
                            .padding(.top, 3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ChevronIcon(color: Theme.text3, size: 14)
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.vertical, 13)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
