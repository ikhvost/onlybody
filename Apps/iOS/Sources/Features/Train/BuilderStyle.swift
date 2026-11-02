import SwiftUI

struct BuilderStyle: View {
    @Bindable var viewModel: SessionBuilderViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            MonoLabel(text: String(localized: .uiSetStyle), size: Theme.typeMeta, color: Theme.text2, tracking: 0.5)
                .padding(.horizontal, Theme.horizontalPadding)

            HStack(spacing: Theme.space8) {
                BuilderModeButton(viewModel: viewModel, label: String(localized: .uiSmartPick), mode: .smart)
                BuilderModeButton(viewModel: viewModel, label: String(localized: .uiIChoose), mode: .manual)
            }
            .padding(.horizontal, Theme.horizontalPadding)
        }
        .padding(.top, Theme.space16)
    }
}
