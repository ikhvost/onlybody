import SwiftUI

struct BuilderStyle: View {
    @Bindable var viewModel: SessionBuilderViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            MonoLabel(text: "Set style", size: Theme.type11, color: Theme.text2, tracking: 0.5)
                .padding(.horizontal, Theme.horizontalPadding)

            HStack(spacing: Theme.space8) {
                BuilderModeButton(viewModel: viewModel, label: "Smart pick", mode: .smart)
                BuilderModeButton(viewModel: viewModel, label: "I choose", mode: .manual)
            }
            .padding(.horizontal, Theme.horizontalPadding)
        }
        .padding(.top, Theme.space16)
    }
}
