import SwiftUI

struct GhostButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.fontSans(Theme.type14, .medium))
                .foregroundStyle(Theme.text2)
                .padding(.horizontal, Theme.space15)
                .padding(.vertical, Theme.space14)
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.border2, lineWidth: 1)
                }
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(PressableButtonStyle())
    }
}
