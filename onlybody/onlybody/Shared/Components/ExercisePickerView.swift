import SwiftUI

struct ExercisePickerView: View {
    @State var viewModel: ExercisePickerViewModel
    var title = String(localized: .uiAddMovement)
    let onAdd: (ExerciseSnapshot) -> Void
    @FocusState private var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Theme.space0) {
            NavBarView(title: title) {
                Button { dismiss() } label: {
                    ChevronIcon(isBack: true).frame(width: Theme.touchSize, height: Theme.touchSize)
                }.accessibilityLabel(String(localized: .uiBack)).accessibilityIdentifier("exercisePicker.close")
            }
            ExerciseCatalogControls(search: $viewModel.searchText, muscle: $viewModel.selectedFilter,
                                    difficulty: $viewModel.selectedDifficulty, searchFocus: $isSearchFocused, searchIdentifier: "exercisePicker.search")
            if viewModel.filteredExercises.isEmpty {
                Text(.uiNoMovementsFound).font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text2)
                GhostButton(title: String(localized: .uiDesignClearFilters), action: viewModel.clearFilters)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.space8) {
                        ForEach(viewModel.filteredExercises) { exercise in
                            LibraryExerciseRow(exercise: exercise) { onAdd(exercise); dismiss() }
                                .accessibilityIdentifier("exercise.pick.\(exercise.name)")
                        }
                    }
                }.scrollIndicators(.hidden).scrollDismissesKeyboard(.interactively)
            }
        }
        .background(Theme.bg).foregroundStyle(Theme.text).preferredColorScheme(.dark)
    }
}
