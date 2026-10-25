import SwiftUI

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space10) {
            MonoLabel(text: title, size: Theme.type10, color: Theme.text2, tracking: 1.2)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: Theme.space0) {
                content
            }
            .background(Theme.surface)
            .clipShape(.rect(cornerRadius: Theme.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .strokeBorder(Theme.border)
            }
        }
    }
}
