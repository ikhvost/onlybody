import SwiftUI

struct BuilderName: View {
    @Bindable var viewModel: SessionBuilderViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            MonoLabel(text: String(localized: .uiSessionName), size: Theme.typeMeta, color: Theme.text2, tracking: 0.5)
                .padding(.horizontal, Theme.horizontalPadding).accessibilityIdentifier("builder.name.label")

            WorkoutNameField(name: $viewModel.name, identifier: "builder.name")
                .padding(.horizontal, Theme.horizontalPadding)
        }
        .padding(.top, Theme.space16)
    }
}
