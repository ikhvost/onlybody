import SwiftUI

struct ExerciseCatalogControls: View {
    @Binding var search: String
    @Binding var muscle: String
    @Binding var difficulty: ExerciseDifficulty?
    var searchFocus: FocusState<Bool>.Binding
    var searchIdentifier = "library.search"
    @State private var showingFilters = false
    private var count: Int { (muscle == "All" ? 0 : 1) + (difficulty == nil ? 0 : 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space12) {
            HStack(spacing: Theme.space12) {
                SearchIcon(color: Theme.text2)
                TextField(String(localized: .uiSearch), text: $search, prompt: Text(.uiSearch).foregroundStyle(Theme.text3))
                    .font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                    .accessibilityIdentifier(searchIdentifier)
                    .focused(searchFocus).submitLabel(.done)
                    .onSubmit { searchFocus.wrappedValue = false }
            }
            .padding(Theme.cardInset).frame(minHeight: Theme.buttonHeight)
            .background(Theme.surface, in: .rect(cornerRadius: Theme.buttonRadius))
            Button { showingFilters = true } label: {
                HStack {
                    Text(.uiDesignFilters)
                    Text(count, format: .number).font(Theme.fontMono(Theme.typeBody))
                }.font(Theme.fontSans(Theme.typeBody)).frame(minHeight: Theme.touchSize)
            }
            .foregroundStyle(Theme.text).accessibilityIdentifier("catalog.filters")
            if count > 0 {
                Text([muscle == "All" ? "" : CatalogLocalization.label(muscle), difficulty?.label ?? ""]
                    .filter { !$0.isEmpty }.joined(separator: " · "))
                    .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            }
        }
        .padding(Theme.horizontalPadding)
        .sheet(isPresented: $showingFilters) {
            ExerciseFilterSheet(muscle: $muscle, difficulty: $difficulty)
                .presentationDetents([.large]).presentationDragIndicator(.visible)
        }
    }
}
