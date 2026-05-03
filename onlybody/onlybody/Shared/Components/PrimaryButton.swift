import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var disabled: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.fontSans(16, .bold))
                .foregroundStyle(disabled ? Theme.text3 : Theme.accentDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(disabled ? Theme.surface2 : Theme.accent)
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
        }
        .disabled(disabled)
        .buttonStyle(.plain)
    }
}
