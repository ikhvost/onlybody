import SwiftUI

struct SettingsNotificationsLink: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.space16) {
                Text(.uiNotifications)
                    .font(Theme.fontSans(Theme.typeBody, .medium))
                    .foregroundStyle(Theme.text)
                Spacer()
                ChevronIcon(color: Theme.text2, size: Theme.typeMeta)
            }
            .frame(minHeight: Theme.touchSize)
            .padding(Theme.space16)
            .contentShape(.rect)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityIdentifier("settings.notifications")
    }
}
