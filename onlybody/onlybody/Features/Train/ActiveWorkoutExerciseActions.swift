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
                    Text("Guide")
                }
                .frame(maxWidth: .infinity, minHeight: Theme.space48)
                .background(Theme.surface2)
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
            }
            .disabled(!canShowGuide)
            .accessibilityLabel("Open exercise guide")
            .accessibilityIdentifier("active.guide")

            Button(action: onHistory) {
                HStack(spacing: Theme.space8) {
                    LogIcon(color: Theme.accent, size: Theme.type18)
                    Text("History")
                }
                .frame(maxWidth: .infinity, minHeight: Theme.space48)
                .background(Theme.surface2)
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
            }
            .disabled(!canShowHistory)
            .accessibilityLabel("Show exercise history")
            .accessibilityIdentifier("active.history")
        }
        .font(Theme.fontSans(Theme.type14, .semibold))
        .foregroundStyle(Theme.text)
        .buttonStyle(PressableButtonStyle())
    }
}
