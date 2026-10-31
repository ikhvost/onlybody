import SwiftUI

struct BuilderDays: View {
    @Bindable var viewModel: SessionBuilderViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            MonoLabel(text: String(localized: .uiTrainingDays), size: Theme.typeMeta, color: Theme.text2, tracking: 0.5)

            FlowLayout(spacing: Theme.space8) {
                ForEach(viewModel.dayNames, id: \.self) { day in
                    ChipView(
                        label: CatalogLocalization.label(day),
                        isActive: viewModel.scheduledDays.contains(day),
                        size: Theme.typeMeta,
                        horizontalPadding: Theme.space12,
                        verticalPadding: Theme.space12
                    ) {
                        viewModel.toggleDay(day)
                    }
                }
            }

            if viewModel.scheduledDays.isEmpty {
                MonoLabel(
                    text: String(localized: .uiNoDaysScheduled),
                    size: Theme.typeMeta,
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
