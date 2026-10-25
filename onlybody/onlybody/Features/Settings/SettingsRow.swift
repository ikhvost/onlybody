import SwiftUI

/// A visibly unavailable destination until its support or legal link is configured.
struct SettingsRow: View {
    let title: String
    let identifier: String

    var body: some View {
        Button {} label: {
            HStack(spacing: Theme.space16) {
                Text(title)
                    .font(Theme.fontSans(Theme.type14, .medium))
                    .foregroundStyle(Theme.text)
                Spacer(minLength: Theme.space8)
                MonoLabel(text: "Soon", size: Theme.type10, color: Theme.text2, tracking: 0.5)
            }
            .frame(minHeight: Theme.space24)
            .padding(Theme.space16)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(true)
        .accessibilityLabel(title)
        .accessibilityValue("Coming soon")
        .accessibilityIdentifier(identifier)
    }
}
