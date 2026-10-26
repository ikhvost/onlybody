import SwiftUI

struct BuilderSmartInfo: View {
    @Bindable var viewModel: SessionBuilderViewModel

    var body: some View {
        if viewModel.mode == .smart {
            VStack(alignment: .leading, spacing: Theme.space4) {
                Text(.uiAutoSelectedMovements)
                    .font(Theme.fontSans(Theme.type14, .bold))
                    .foregroundStyle(Theme.text)

                Text(smartInfoDescription)
                    .font(Theme.fontSans(Theme.type14))
                    .foregroundStyle(Theme.text2)
                    .lineSpacing(4)
            }
            .padding(Theme.space14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .clipShape(.rect(cornerRadius: Theme.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Theme.border, lineWidth: 1)
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, Theme.space14)
        }
    }
    private var smartInfoDescription: String {
        if viewModel.targetMuscleGroups.isEmpty {
            return String(localized: .uiSmartDescription)
        }

        let formatted = viewModel.targetMuscleGroups.map { CatalogLocalization.label($0) }.joined(separator: ", ")
        return String(localized: .uiSmartDescriptionTargets(formatted))
    }
}
