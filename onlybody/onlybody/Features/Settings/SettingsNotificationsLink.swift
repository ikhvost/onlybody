import SwiftUI

struct SettingsNotificationsLink: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.space16) {
                Text("Notifications")
                    .font(Theme.fontSans(Theme.type14, .medium))
                    .foregroundStyle(Theme.text)
                Spacer()
                ChevronIcon(color: Theme.text2, size: Theme.type14)
            }
            .frame(minHeight: Theme.space24)
            .padding(Theme.space16)
            .contentShape(.rect)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityIdentifier("settings.notifications")
    }
}
