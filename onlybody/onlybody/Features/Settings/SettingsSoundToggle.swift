import SwiftUI

struct SettingsSoundToggle: View {
    @Binding var isEnabled: Bool

    var body: some View {
        Toggle(isOn: $isEnabled) {
            VStack(alignment: .leading, spacing: Theme.space4) {
                Text("Timer sound")
                    .font(Theme.fontSans(Theme.type14, .medium))
                    .foregroundStyle(Theme.text)
                Text("Play a sound when rest ends")
                    .font(Theme.fontSans(Theme.type11))
                    .foregroundStyle(Theme.text2)
            }
        }
        .toggleStyle(.switch)
        .tint(Theme.accent)
        .frame(minHeight: Theme.space44)
        .padding(Theme.space16)
        .accessibilityIdentifier("settings.timerSound")
    }
}
