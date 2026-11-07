import SwiftUI

/// Shared dismissal control for modal screens.
struct NavigationCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            CloseIcon().frame(width: Theme.touchSize, height: Theme.touchSize).contentShape(.rect)
        }
        .buttonStyle(.glass).buttonBorderShape(.circle)
        .accessibilityLabel(String(localized: .uiCancel))
    }
}
