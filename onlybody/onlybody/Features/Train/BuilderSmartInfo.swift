import SwiftUI

struct BuilderSmartInfo: View {
    @Bindable var viewModel: SessionBuilderViewModel

    var body: some View {
        if viewModel.mode == .smart {
            VStack(alignment: .leading, spacing: Theme.space4) {
                Text("Auto-selected movements")
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
            return "Movements are picked daily from your targets. Switch to \"I choose\" to build manually."
        }

        let formatted = viewModel.targetMuscleGroups.joined(separator: ", ")
        return "Movements are picked daily from your targets (\(formatted)). Switch to \"I choose\" to build manually."
    }
}
