import SwiftUI

struct CustomBadgeView: View {
    var body: some View {
        MonoLabel(text: "Custom", size: 10, color: Theme.accent, tracking: 0.5)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(Theme.accentDim)
            .clipShape(.rect(cornerRadius: 2))
    }
}
