import SwiftUI

struct GhostButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.fontSans(Theme.typeBody, .medium))
                .foregroundStyle(Theme.text2)
                .padding(.horizontal, Theme.space15)
                .frame(minHeight: Theme.buttonHeight)
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.buttonRadius)
                        .stroke(Theme.border2, lineWidth: 1)
                }
                .clipShape(.rect(cornerRadius: Theme.buttonRadius))
        }
        .buttonStyle(PressableButtonStyle())
    }
}
