import SwiftUI

struct ExercisePickerView: View {
    @State var viewModel: ExercisePickerViewModel
    let makeMovement: (ExerciseSnapshot) -> MovementDetailViewModel
    var title = String(localized: .uiAddMovement)
    let onAdd: (ExerciseSnapshot) -> Void
    @State private var path: [UUID] = []
    @FocusState private var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: Theme.space0) {
                NavBarView(title: title) {
                    NavigationCloseButton { dismiss() }.accessibilityIdentifier("exercisePicker.close")
                }
                ExerciseCatalogControls(search: $viewModel.searchText, muscle: $viewModel.selectedFilter,
                                        equipment: $viewModel.selectedEquipment, equipmentOptions: viewModel.equipmentOptions,
                                        searchFocus: $isSearchFocused, searchIdentifier: "exercisePicker.search")
                if viewModel.filteredExercises.isEmpty {
                    Text(.uiNoMovementsFound).font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text2)
                    GhostButton(title: String(localized: .uiDesignClearFilters), action: viewModel.clearFilters)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: Theme.space8) {
                            ForEach(viewModel.filteredExercises) { exercise in
                                ExercisePickerRow(exercise: exercise, onGuide: {
                                    isSearchFocused = false
                                    path.append(exercise.id)
                                }, onAdd: { onAdd(exercise); dismiss() })
                            }
                        }
                    }.scrollIndicators(.hidden).scrollDismissesKeyboard(.interactively)
                }
            }
            .background(Theme.bg).foregroundStyle(Theme.text).preferredColorScheme(.dark)
            .background(BackActionSwipeBridge(isEnabled: path.isEmpty, onBack: { dismiss() }).allowsHitTesting(false))
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: UUID.self) { id in
                if let exercise = viewModel.filteredExercises.first(where: { $0.id == id }) {
                    MovementDetailView(viewModel: makeMovement(exercise), backLabel: String(localized: .uiBack))
                }
            }
        }
    }
}
