import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var minimumHeight: CGFloat = Theme.buttonHeight
    var disabled: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.fontSans(Theme.typeBody, .bold))
                .foregroundStyle(disabled ? Theme.text3 : Theme.accentDark)
                .frame(maxWidth: .infinity)
                .frame(minHeight: minimumHeight)
                .padding(.horizontal, Theme.cardInset)
                .background(disabled ? Theme.surface2 : Theme.accent)
                .clipShape(.capsule)
        }
        .disabled(disabled)
        .buttonStyle(PressableButtonStyle())
    }
}
