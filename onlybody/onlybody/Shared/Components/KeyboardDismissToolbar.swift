import SwiftUI

/// An explicit dismissal action for keyboards without a Return key.
struct KeyboardDismissToolbar: ToolbarContent {
    let onDismiss: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button(String(localized: .uiDone), action: onDismiss)
                .font(Theme.fontSans(Theme.typeMeta, .semibold))
                .frame(minWidth: Theme.touchSize, minHeight: Theme.touchSize)
                .accessibilityIdentifier("keyboard.dismiss")
        }
    }
}
