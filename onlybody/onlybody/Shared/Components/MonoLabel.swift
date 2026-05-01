import SwiftUI

struct MonoLabel: View {
    let text: String
    var size: CGFloat = 10
    var color: Color = Theme.text3
    var tracking: CGFloat = 1.0

    var body: some View {
        Text(text.uppercased())
            .font(Theme.fontMono(size))
            .foregroundStyle(color)
            .tracking(tracking)
    }
}
