import SwiftUI

struct StatCard: View {
    let label: String
    let value: String
    let isAccent: Bool

    var body: some View {
        VStack(spacing: Theme.space3) {
            Text(value)
                .font(Theme.fontMono(Theme.type28, .medium))
                .foregroundStyle(isAccent ? Theme.accent : Theme.text)
            Text(label).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
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
