import SwiftUI

struct BuilderName: View {
    @Bindable var viewModel: SessionBuilderViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            MonoLabel(text: "Session name", size: Theme.type11, color: Theme.text2, tracking: 0.5)
                .padding(.horizontal, Theme.horizontalPadding)

            TextField("e.g. Full Body", text: $viewModel.name)
                .accessibilityIdentifier("builder.name")
                .font(Theme.fontSans(Theme.type16))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, Theme.space13)
                .padding(.vertical, Theme.space11)
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
    }
}
