import SwiftUI

struct ExerciseCatalogControls: View {
    @Binding var search: String
    @Binding var muscle: String
    @Binding var equipment: String?
    let equipmentOptions: [String]
    var searchFocus: FocusState<Bool>.Binding
    var searchIdentifier = "library.search"
    @State private var showingFilters = false
    private var count: Int { (muscle == "All" ? 0 : 1) + (equipment == nil ? 0 : 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space12) {
            HStack(spacing: Theme.space8) {
                HStack(spacing: Theme.space10) {
                    SearchIcon(color: Theme.text2)
                    TextField(String(localized: .uiSearch), text: $search, prompt: Text(.uiSearch).foregroundStyle(Theme.text3))
                        .font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text)
                        .textInputAutocapitalization(.never).autocorrectionDisabled()
                        .accessibilityIdentifier(searchIdentifier)
                        .focused(searchFocus).submitLabel(.done)
                        .onSubmit { searchFocus.wrappedValue = false }
                }
                .padding(.horizontal, Theme.cardInset).frame(minHeight: Theme.buttonHeight)
                .background(Theme.surface, in: .rect(cornerRadius: Theme.buttonRadius))
                Button { searchFocus.wrappedValue = false; showingFilters = true } label: {
                    FilterIcon(color: count > 0 ? Theme.accent : Theme.text)
                        .frame(width: Theme.buttonHeight, height: Theme.buttonHeight)
                        .background(Theme.surface2, in: .rect(cornerRadius: Theme.buttonRadius))
                        .overlay(alignment: .topTrailing) {
                            if count > 0 {
                                Text(count, format: .number).font(Theme.fontSans(Theme.type12, .semibold))
                                    .foregroundStyle(Theme.accentDark).padding(.horizontal, Theme.space6)
                                    .background(Theme.accent, in: .capsule).accessibilityHidden(true)
                            }
                        }
                }
                .accessibilityLabel(String(localized: .uiDesignFilters))
                .accessibilityValue(count.formatted())
                .accessibilityIdentifier("catalog.filters")
            }
            if count > 0 {
                Text([muscle == "All" ? "" : CatalogLocalization.label(muscle), equipment.map { CatalogLocalization.label($0) } ?? ""]
                    .filter { !$0.isEmpty }.joined(separator: " · "))
                    .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            }
        }
        .padding(Theme.horizontalPadding)
        .background(KeyboardOutsideTapBridge(isEnabled: searchFocus.wrappedValue) {
            searchFocus.wrappedValue = false
        }.allowsHitTesting(false))
        .onDisappear { searchFocus.wrappedValue = false }
        .sheet(isPresented: $showingFilters) {
            ExerciseFilterSheet(muscle: $muscle, equipment: $equipment, equipmentOptions: equipmentOptions)
                .presentationDetents([.large]).presentationDragIndicator(.visible)
        }
    }
}
