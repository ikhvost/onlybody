import SwiftUI

struct GhostButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.fontSans(13, .medium))
                .foregroundStyle(Theme.text2)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.border2, lineWidth: 1)
                }
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}
