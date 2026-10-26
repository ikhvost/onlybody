import SwiftUI

struct ActiveWorkoutTopBar: View {
    let currentIndex: Int
    let totalCount: Int
    let elapsedString: String
    let onEnd: () -> Void

    var body: some View {
        HStack(spacing: Theme.space0) {
            MonoLabel(
                text: "\(currentIndex + 1)/\(totalCount)",
                size: Theme.type12,
                color: Theme.text3,
                tracking: 0.5
            )

            Spacer()

            Text(elapsedString)
                .font(Theme.fontMono(Theme.type15, .regular))
                .foregroundStyle(Theme.text2)
                .tracking(-0.5)

            Spacer()

            GhostButton(title: String(localized: .uiEnd), action: onEnd)
                .accessibilityIdentifier("active.end")
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.vertical, Theme.space8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)
        }
    }
}
