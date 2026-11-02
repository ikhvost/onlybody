import SwiftUI

struct MonoLabel: View {
    let text: String
    var size: CGFloat = Theme.typeMeta
    var color: Color = Theme.text3
    var tracking: CGFloat = 1.0

    var body: some View {
        Text(text)
            .font(Theme.fontSans(size))
            .foregroundStyle(color)
            .tracking(0)
    }
}
