import SwiftUI

struct LibraryView: View {
    @Bindable var viewModel: LibraryViewModel
    @FocusState private var isSearchFocused: Bool

    let showMovement: (ExerciseSnapshot) -> Void

    private var contentState: String {
        if viewModel.isLoading { return "loading" }
        if viewModel.errorMessage != nil { return "error" }
        return "ready"
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Theme.space0) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: Theme.space3) {
                        MonoLabel(text: String(localized: .uiMovementCatalog), size: Theme.typeMeta, tracking: 1.2)

                        Text(.uiDesignExercises)
                            .font(Theme.fontSans(Theme.typeHeading, .heavy))
                            .tracking(-1)
                            .foregroundStyle(Theme.text)
                    }

                    Spacer(minLength: 10)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.top, Theme.space16)
                .padding(.bottom, Theme.space10)

                ExerciseCatalogControls(search: $viewModel.searchText, muscle: $viewModel.selectedFilter,
                                        difficulty: $viewModel.selectedDifficulty, searchFocus: $isSearchFocused)

                Rectangle()
                    .fill(Theme.border)
                    .frame(height: 1)

                ZStack {
                    if viewModel.isLoading {
                        VStack(spacing: Theme.space8) {
                            MonoLabel(text: String(localized: .uiLoadingLibrary), size: Theme.typeMeta, tracking: 1.0)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: Theme.space8) {
                            MonoLabel(text: errorMessage, size: Theme.typeMeta, color: Theme.text2, tracking: 0.4)
                            GhostButton(title: String(localized: .uiRetry)) { Task { await viewModel.load() } }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, Theme.horizontalPadding)
                        .transition(.opacity)
                    } else if viewModel.filteredExercises.isEmpty {
                        VStack(spacing: Theme.space8) {
                            MonoLabel(text: String(localized: .uiNoMovementsFound), size: Theme.typeMeta, color: Theme.text2, tracking: 0.4)
                            GhostButton(title: String(localized: .uiDesignClearFilters), action: viewModel.clearFilters)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, Theme.horizontalPadding)
                        .transition(.opacity)
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: Theme.space0) {
                                ForEach(viewModel.displayedExercises) { exercise in
                                    LibraryExerciseRow(exercise: exercise) {
                                        isSearchFocused = false
                                        showMovement(exercise)
                                    }
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                        .scrollDismissesKeyboard(.interactively)
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: contentState)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#if DEBUG
#Preview("Library") {
    var pushUps = ExerciseSnapshot()
    pushUps.name = "Push-Ups"
    pushUps.primaryMuscle = "Chest"
    pushUps.equipment = ["None"]

    var splitSquats = ExerciseSnapshot()
    splitSquats.name = "Bulgarian Split Squats"
    splitSquats.primaryMuscle = "Quads"
    splitSquats.equipment = ["None"]

    let viewModel = LibraryViewModel(
        exercises: PreviewExerciseRepository(exercises: [pushUps, splitSquats])
    )

    return LibraryView(
        viewModel: viewModel,
        showMovement: { _ in }
    )
    .preferredColorScheme(.dark)
}
#endif
