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
                .background(Theme.surface2, in: .capsule)
        }
        .buttonStyle(PressableButtonStyle())
    }
}
