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
            MonoLabel(text: "Session complete", size: Theme.type11, color: Theme.text3, tracking: 2)

            Text(elapsedString)
                .font(Theme.fontMono(Theme.type72, .medium))
                .foregroundStyle(Theme.accent)
                .tracking(-3)
                .lineLimit(1)
                .padding(.top, Theme.space12)

            MonoLabel(
                text: "\(exerciseCount) movements done",
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
                GhostButton(title: "Retry save", action: onRetry)
            }

            PrimaryButton(title: "Close") {
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
