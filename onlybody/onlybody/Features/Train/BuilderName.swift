import SwiftUI

struct BuilderName: View {
    @FocusState private var isFocused: Bool
    @Bindable var viewModel: SessionBuilderViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            MonoLabel(text: String(localized: .uiSessionName), size: Theme.typeMeta, color: Theme.text2, tracking: 0.5)
                .padding(.horizontal, Theme.horizontalPadding).accessibilityIdentifier("builder.name.label")

            TextField(String(localized: .uiEGFullBody), text: $viewModel.name,
                      prompt: Text(.uiEGFullBody).foregroundStyle(Theme.text3))
                .accessibilityIdentifier("builder.name")
                .focused($isFocused).submitLabel(.done)
                .onSubmit { isFocused = false }
                .font(Theme.fontSans(Theme.typeBody))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, Theme.space13)
                .padding(.vertical, Theme.cardInset)
                .background(Theme.surface)
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.border2, lineWidth: 1)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.top, Theme.space16)
        .background(KeyboardOutsideTapBridge(isEnabled: isFocused) { isFocused = false }.allowsHitTesting(false))
        .onDisappear { isFocused = false }
    }
}
