import SwiftUI

/// Opens a configured link or shows an unavailable destination.
struct SettingsRow: View {
    let title: String
    let identifier: String
    var destination: URL?
    var destinationDescription = String(localized: .uiOpensInBrowser)
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            if let destination {
                openURL(destination)
            }
        } label: {
            HStack(spacing: Theme.space16) {
                Text(title)
                    .font(Theme.fontSans(Theme.type14, .medium))
                    .foregroundStyle(Theme.text)
                Spacer(minLength: Theme.space8)
                if destination != nil {
                    ChevronIcon(color: Theme.text2, size: Theme.type18)
                } else {
                    MonoLabel(text: String(localized: .uiSoon), size: Theme.type10, color: Theme.text2, tracking: 0.5)
                }
            }
            .frame(minHeight: Theme.space24)
            .padding(Theme.space16)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(destination == nil)
        .accessibilityLabel(title)
        .accessibilityValue(destination == nil ? String(localized: .uiComingSoon) : destinationDescription)
        .accessibilityIdentifier(identifier)
    }
}
