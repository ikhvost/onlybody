import SwiftUI

struct ActiveWorkoutCompletionView: View {
    let elapsedString: String
    let exerciseCount: Int
    let saveState: SessionSaveState
    let onRetry: () -> Void
    let errorMessage: String?
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: Theme.space0) {
            Spacer()
            MonoLabel(text: String(localized: .uiSessionComplete), size: Theme.type11, color: Theme.text3, tracking: 2)

            Text(elapsedString)
                .font(Theme.fontMono(Theme.type72, .medium))
                .foregroundStyle(Theme.accent)
                .tracking(-3)
                .lineLimit(1)
                .padding(.top, Theme.space12)

            MonoLabel(
                text: String(localized: .uiCompletedMovements(exerciseCount)),
                size: Theme.type12,
                color: Theme.text2,
                tracking: 1
            )
            .padding(.top, Theme.space10)

            if let error = errorMessage {
                MonoLabel(
                    text: error,
                    size: Theme.type10,
                    color: Theme.danger,
                    tracking: 0.4
                )
                .padding(.top, Theme.space10)
            }

            if saveState == .failed {
                GhostButton(title: String(localized: .uiRetrySave), action: onRetry)
            }

            PrimaryButton(title: String(localized: .uiClose)) {
                onEnd()
            }
            .accessibilityIdentifier("active.close")
            .disabled(saveState != .saved)
            .frame(maxWidth: 200)
            .padding(.top, Theme.space48)

            Spacer()
        }
        .padding(.horizontal, Theme.horizontalPadding)
    }
}
