import SwiftUI

struct RestOverlayView: View {
    let remainingString: String
    let nextExerciseName: String
    let onSkip: () -> Void

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                MonoLabel(text: String(localized: .uiRecovery), size: Theme.type11, color: Theme.text3, tracking: 3)
                    .padding(.bottom, Theme.space18)

                Text(remainingString)
                    .font(Theme.fontMono(Theme.type84, .medium))
                    .foregroundStyle(Theme.accent)
                    .tracking(-4)
                    .lineLimit(1)

                if !nextExerciseName.isEmpty {
                    MonoLabel(
                        text: String(localized: .uiNextExercise(nextExerciseName)),
                        size: Theme.type11,
                        color: Theme.text3,
                        tracking: 1.5
                    )
                    .padding(.top, Theme.space18)
                }

                GhostButton(title: String(localized: .uiSkipRest)) {
                    onSkip()
                }
                .accessibilityIdentifier("rest.skip")
                .padding(.top, Theme.space44)
            }
        }
    }
}
