import SwiftUI

struct ExerciseDifficultyBadge: View {
    let difficulty: ExerciseDifficulty

    var body: some View {
        Text(difficulty.label)
            .font(Theme.fontMono(Theme.type10, .medium))
            .foregroundStyle(Theme.accent)
            .padding(.horizontal, Theme.space8)
            .padding(.vertical, Theme.space4)
            .background(Theme.accentDim, in: .rect(cornerRadius: Theme.chipCornerRadius))
            .accessibilityLabel(String(localized: .uiDifficulty(difficulty.label)))
    }
}
