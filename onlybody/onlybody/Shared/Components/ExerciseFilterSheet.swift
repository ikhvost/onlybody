import SwiftUI

struct ExerciseFilterSheet: View {
    @Binding var muscle: String
    @Binding var difficulty: ExerciseDifficulty?
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
                Text(.uiAllLevels).font(Theme.fontSans(Theme.typeCard, .semibold))
                FlowLayout(spacing: Theme.space8) {
                    ChipView(label: String(localized: .uiAllLevels), isActive: difficulty == nil) { difficulty = nil }
                        .accessibilityIdentifier("difficulty.all")
                    ForEach(ExerciseDifficulty.allCases, id: \.self) { level in
                        ChipView(label: level.label, isActive: difficulty == level) { difficulty = level }
                            .accessibilityIdentifier("difficulty.\(level.rawValue)")
                    }
                }
                GhostButton(title: String(localized: .uiDesignClearFilters)) { muscle = "All"; difficulty = nil }
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
