import SwiftUI

/// Consistent workout-name editing, including Done, scrolling and outside-tap keyboard dismissal.
struct WorkoutNameField: View {
    @Binding var name: String
    let identifier: String
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField(String(localized: .uiEGFullBody), text: $name,
                  prompt: Text(.uiEGFullBody).foregroundStyle(Theme.text3))
            .accessibilityIdentifier(identifier)
            .focused($isFocused).submitLabel(.done)
            .onSubmit { isFocused = false }
            .font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text)
            .padding(.horizontal, Theme.space13).padding(.vertical, Theme.cardInset)
            .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
            .overlay { RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.border2, lineWidth: Theme.dividerThickness) }
            .textInputAutocapitalization(.never).autocorrectionDisabled()
            .background(KeyboardOutsideTapBridge(isEnabled: isFocused) { isFocused = false }.allowsHitTesting(false))
            .onDisappear { isFocused = false }
    }
}
