import SwiftUI

struct ExercisePickerView<Options: View>: View {
    @State var viewModel: ExercisePickerViewModel
    let makeMovement: (ExerciseSnapshot) -> MovementDetailViewModel
    var title = String(localized: .uiAddMovement)
    let emptyMessage: String
    let isDismissDisabled: Bool
    let options: Options
    let onAdd: (ExerciseSnapshot) -> Void
    @State private var path: [UUID] = []
    @FocusState private var isSearchFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ExercisePickerViewModel, makeMovement: @escaping (ExerciseSnapshot) -> MovementDetailViewModel,
         title: String = String(localized: .uiAddMovement), emptyMessage: String = String(localized: .uiNoMovementsFound),
         isDismissDisabled: Bool = false,
         @ViewBuilder options: () -> Options = { EmptyView() },
         onAdd: @escaping (ExerciseSnapshot) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.makeMovement = makeMovement
        self.title = title
        self.emptyMessage = emptyMessage
        self.isDismissDisabled = isDismissDisabled
        self.options = options()
        self.onAdd = onAdd
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: Theme.space0) {
                NavBarView(title: title) {
                    NavigationCloseButton { dismiss() }.accessibilityIdentifier("exercisePicker.close").disabled(isDismissDisabled)
                }
                options
                ExerciseCatalogControls(search: $viewModel.searchText, muscle: $viewModel.selectedFilter,
                                        equipment: $viewModel.selectedEquipment, equipmentOptions: viewModel.equipmentOptions,
                                        searchFocus: $isSearchFocused, searchIdentifier: "exercisePicker.search")
                if viewModel.filteredExercises.isEmpty {
                    Text(emptyMessage).font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text2)
                        .multilineTextAlignment(.center).padding(.horizontal, Theme.horizontalPadding)
                        .accessibilityIdentifier("exercisePicker.empty")
                    if viewModel.hasActiveFilters {
                        GhostButton(title: String(localized: .uiDesignClearFilters), action: viewModel.clearFilters)
                            .accessibilityIdentifier("exercisePicker.clearFilters")
                    }
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
            .background(BackActionSwipeBridge(isEnabled: path.isEmpty && !isDismissDisabled, onBack: { dismiss() }).allowsHitTesting(false))
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: UUID.self) { id in
                if let exercise = viewModel.filteredExercises.first(where: { $0.id == id }) {
                    MovementDetailView(viewModel: makeMovement(exercise), backLabel: String(localized: .uiBack))
                }
            }
        }
    }
}
