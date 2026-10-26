import SwiftUI

struct BuilderDays: View {
    @Bindable var viewModel: SessionBuilderViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            MonoLabel(text: String(localized: .uiTrainingDays), size: Theme.type11, color: Theme.text2, tracking: 0.5)

            HStack(spacing: Theme.space2) {
                ForEach(viewModel.dayNames, id: \.self) { day in
                    ChipView(
                        label: CatalogLocalization.label(day),
                        isActive: viewModel.scheduledDays.contains(day),
                        size: Theme.type12,
                        horizontalPadding: 8,
                        verticalPadding: 6
                    ) {
                        viewModel.toggleDay(day)
                    }
                }
            }

            if viewModel.scheduledDays.isEmpty {
                MonoLabel(
                    text: String(localized: .uiNoDaysScheduled),
                    size: Theme.type11,
                    color: Theme.text3,
                    tracking: 0.3
                )
                .padding(.top, Theme.space8)
            }
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, Theme.space16)
    }
}
