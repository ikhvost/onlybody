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
                .frame(maxWidth: .infinity, minHeight: Theme.space48)
                .background(Theme.surface2)
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
            }
            .disabled(!canShowGuide)
            .accessibilityLabel(String(localized: .uiOpenExerciseGuide))
            .accessibilityIdentifier("active.guide")

            Button(action: onHistory) {
                HStack(spacing: Theme.space8) {
                    LogIcon(color: Theme.accent, size: Theme.type18)
                    Text(.uiHistory)
                }
                .frame(maxWidth: .infinity, minHeight: Theme.space48)
                .background(Theme.surface2)
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
            }
            .disabled(!canShowHistory)
            .accessibilityLabel(String(localized: .uiShowExerciseHistory))
            .accessibilityIdentifier("active.history")
        }
        .font(Theme.fontSans(Theme.type14, .semibold))
        .foregroundStyle(Theme.text)
        .buttonStyle(PressableButtonStyle())
    }
}
