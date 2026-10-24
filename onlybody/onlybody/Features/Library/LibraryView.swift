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
                        MonoLabel(text: "Movement catalog", size: Theme.type10, tracking: 1.2)

                        Text("Library")
                            .font(Theme.fontSans(Theme.type28, .heavy))
                            .tracking(-1)
                            .foregroundStyle(Theme.text)
                    }

                    Spacer(minLength: 10)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.top, Theme.space16)
                .padding(.bottom, Theme.space10)

                VStack(spacing: Theme.space8) {
                    HStack(spacing: Theme.space8) {
                        SearchIcon(color: Theme.text3, size: Theme.type15)

                        TextField("Search...", text: $viewModel.searchText)
                            .accessibilityIdentifier("library.search")
                            .focused($isSearchFocused)
                            .submitLabel(.done)
                            .onSubmit { isSearchFocused = false }
                            .font(Theme.fontSans(Theme.type14))
                            .foregroundStyle(Theme.text)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, Theme.space10)
                    .padding(.vertical, Theme.space9)
                    .background(Theme.surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(Theme.border2, lineWidth: 1)
                    }
                    .clipShape(.rect(cornerRadius: Theme.cornerRadius))

                    ScrollView(.horizontal) {
                        HStack(spacing: Theme.space6) {
                            ForEach(viewModel.filters, id: \.self) { filter in
                                ChipView(label: filter, isActive: viewModel.selectedFilter == filter, isSmall: true) {
                                    viewModel.selectedFilter = filter
                                }
                            }
                        }
                        .padding(.bottom, Theme.space2)
                    }
                    .scrollIndicators(.hidden)

                    ExerciseDifficultyFilter(selection: $viewModel.selectedDifficulty)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, Theme.space10)

                Rectangle()
                    .fill(Theme.border)
                    .frame(height: 1)

                ZStack {
                    if viewModel.isLoading {
                        VStack(spacing: Theme.space8) {
                            MonoLabel(text: "Loading library", size: Theme.type11, tracking: 1.0)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: Theme.space8) {
                            MonoLabel(text: errorMessage, size: Theme.type11, color: Theme.text2, tracking: 0.4)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, Theme.horizontalPadding)
                        .transition(.opacity)
                    } else if viewModel.filteredExercises.isEmpty {
                        VStack(spacing: Theme.space8) {
                            MonoLabel(text: "No movements found", size: Theme.type11, color: Theme.text2, tracking: 0.4)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, Theme.horizontalPadding)
                        .transition(.opacity)
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: Theme.space0) {
                                ForEach(viewModel.sections) { section in
                                    LibraryDifficultyHeader(section: section)
                                    ForEach(section.exercises) { exercise in
                                        LibraryExerciseRow(exercise: exercise) {
                                            isSearchFocused = false
                                            showMovement(exercise)
                                        }
                                        Rectangle()
                                            .fill(Theme.border)
                                            .frame(height: 1)
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
