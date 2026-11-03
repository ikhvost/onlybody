import SwiftUI

struct ActiveWorkoutExerciseActions: View {
    let canShowGuide: Bool
    let canShowHistory: Bool
    let onGuide: () -> Void
    let onHistory: () -> Void

    var body: some View {
        HStack(spacing: Theme.space10) {
            Button(action: onGuide) {
                HStack(spacing: Theme.space8) {
                    LibraryIcon(color: Theme.accent, size: Theme.type18)
                    Text(.uiGuide)
                }
                .frame(minHeight: Theme.touchSize)
                .padding(.horizontal, Theme.space8)
            }
            .disabled(!canShowGuide)
            .accessibilityLabel(String(localized: .uiOpenExerciseGuide))
            .accessibilityIdentifier("active.guide")

            Button(action: onHistory) {
                HStack(spacing: Theme.space8) {
                    LogIcon(color: Theme.accent, size: Theme.type18)
                    Text(.uiHistory)
                }
                .frame(minHeight: Theme.touchSize)
                .padding(.horizontal, Theme.space8)
            }
            .disabled(!canShowHistory)
            .accessibilityLabel(String(localized: .uiShowExerciseHistory))
            .accessibilityIdentifier("active.history")
        }
        .font(Theme.fontSans(Theme.typeMeta, .semibold))
        .foregroundStyle(Theme.text)
        .buttonStyle(PressableButtonStyle())
    }
}
