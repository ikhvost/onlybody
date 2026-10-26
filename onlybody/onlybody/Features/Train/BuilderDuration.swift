import SwiftUI

struct BuilderDuration: View {
    @Bindable var viewModel: SessionBuilderViewModel

    var body: some View {
        if !viewModel.movements.isEmpty {
            HStack {
                Text(.uiEstDuration)
                    .font(Theme.fontSans(Theme.type14))
                    .foregroundStyle(Theme.text2)

                Spacer()

                Text(String(localized: .uiEstimatedMinutes(viewModel.estimatedDurationMinutes)))
                    .font(Theme.fontMono(Theme.type14, .medium))
                    .foregroundStyle(Theme.accent)
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, Theme.space14)
            .padding(.bottom, Theme.space10)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Theme.border)
                    .frame(height: 1)
                    .padding(.horizontal, Theme.horizontalPadding)
            }
        }
    }
}
