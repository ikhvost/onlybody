import SwiftUI

/// Shared navigation control for pushed screens and steps inside a flow.
struct NavigationBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ChevronIcon(isBack: true, color: Theme.text, size: Theme.type18, inset: Theme.space8)
                .frame(width: Theme.touchSize, height: Theme.touchSize)
                .contentShape(.rect)
        }
        .buttonStyle(.glass).buttonBorderShape(.circle)
        .accessibilityLabel(String(localized: .uiBack))
    }
}
