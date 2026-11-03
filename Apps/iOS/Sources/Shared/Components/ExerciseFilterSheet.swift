import SwiftUI

struct ExerciseFilterSheet: View {
    @Binding var muscle: String
    @Binding var equipment: String?
    let equipmentOptions: [String]
    @State private var draftMuscle: String
    @State private var draftEquipment: String?
    @Environment(\.dismiss) private var dismiss

    init(muscle: Binding<String>, equipment: Binding<String?>, equipmentOptions: [String]) {
        _muscle = muscle
        _equipment = equipment
        self.equipmentOptions = equipmentOptions
        _draftMuscle = State(initialValue: muscle.wrappedValue)
        _draftEquipment = State(initialValue: equipment.wrappedValue)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.sectionGap) {
                HStack {
                    Text(.uiDesignFilters).font(Theme.fontSans(Theme.typeHeading, .bold))
                    Spacer()
                    Button { dismiss() } label: { CloseIcon().frame(width: Theme.touchSize, height: Theme.touchSize) }
                        .buttonStyle(NavigationControlStyle()).accessibilityLabel(String(localized: .uiCancel))
                        .accessibilityIdentifier("filters.close")
                }
                Text(.uiPrimaryMuscles).font(Theme.fontSans(Theme.typeCard, .semibold))
                FlowLayout(spacing: Theme.space8) {
                    ForEach(ExerciseCatalog.filters, id: \.self) { filter in
                        ChipView(label: CatalogLocalization.label(filter), isActive: draftMuscle == filter) { draftMuscle = filter }
                            .accessibilityIdentifier("filter.\(filter)")
                    }
                }
                Text(.uiEquipment).font(Theme.fontSans(Theme.typeCard, .semibold))
                FlowLayout(spacing: Theme.space8) {
                    ChipView(label: CatalogLocalization.label("All"), isActive: draftEquipment == nil) { draftEquipment = nil }
                        .accessibilityIdentifier("equipment.all")
                    ForEach(equipmentOptions, id: \.self) { option in
                        ChipView(label: CatalogLocalization.label(option), isActive: draftEquipment == option) { draftEquipment = option }
                            .accessibilityIdentifier("equipment.\(option)")
                    }
                }
                GhostButton(title: String(localized: .uiDesignClearFilters)) { draftMuscle = "All"; draftEquipment = nil }
                    .accessibilityIdentifier("filters.clear")
            }.padding(Theme.horizontalPadding)
        }.scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: String(localized: .uiDone)) { muscle = draftMuscle; equipment = draftEquipment; dismiss() }
                .accessibilityIdentifier("filters.done").padding(Theme.cardInset).background(Theme.bg)
        }
        .foregroundStyle(Theme.text).background(Theme.bg).preferredColorScheme(.dark)
    }
}
