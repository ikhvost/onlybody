import SwiftUI

struct ExerciseFilterSheet: View {
    @Binding var muscle: String
    @Binding var equipment: String?
    let equipmentOptions: [String]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.sectionGap) {
                Text(.uiDesignFilters).font(Theme.fontSans(Theme.typeHeading, .bold))
                Text(.uiPrimaryMuscles).font(Theme.fontSans(Theme.typeCard, .semibold))
                FlowLayout(spacing: Theme.space8) {
                    ForEach(ExerciseCatalog.filters, id: \.self) { filter in
                        ChipView(label: CatalogLocalization.label(filter), isActive: muscle == filter) { muscle = filter }
                            .accessibilityIdentifier("filter.\(filter)")
                    }
                }
                Text(.uiEquipment).font(Theme.fontSans(Theme.typeCard, .semibold))
                FlowLayout(spacing: Theme.space8) {
                    ChipView(label: CatalogLocalization.label("All"), isActive: equipment == nil) { equipment = nil }
                        .accessibilityIdentifier("equipment.all")
                    ForEach(equipmentOptions, id: \.self) { option in
                        ChipView(label: CatalogLocalization.label(option), isActive: equipment == option) { equipment = option }
                            .accessibilityIdentifier("equipment.\(option)")
                    }
                }
                GhostButton(title: String(localized: .uiDesignClearFilters)) { muscle = "All"; equipment = nil }
                    .accessibilityIdentifier("filters.clear")
            }.padding(Theme.horizontalPadding)
        }.scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: String(localized: .uiDone)) { dismiss() }
                .accessibilityIdentifier("filters.done").padding(Theme.cardInset).background(Theme.bg)
        }
        .foregroundStyle(Theme.text).background(Theme.bg).preferredColorScheme(.dark)
    }
}
