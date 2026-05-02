import SwiftUI

struct StatCardView: View {
    let label: String
    let value: String
    let isAccent: Bool

    var body: some View {
        VStack(spacing: Theme.space3) {
            Text(value)
                .font(Theme.fontMono(28, .medium))
                .foregroundStyle(isAccent ? Theme.accent : Theme.text3)
            MonoLabel(text: label, size: 8, color: Theme.text3, tracking: 1.2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.space14)
        .background(Theme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.border, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}
