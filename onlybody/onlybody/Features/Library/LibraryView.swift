import SwiftUI

struct LibraryView: View {
    @Bindable var viewModel: LibraryViewModel

    let showMovement: (Exercise) -> Void

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        MonoLabel(text: "Movement catalog", size: 10, tracking: 1.2)

                        Text("Library")
                            .font(Theme.fontSans(28, .heavy))
                            .tracking(-1)
                            .foregroundStyle(Theme.text)
                    }

                    Spacer(minLength: 10)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.top, 16)
                .padding(.bottom, 10)

                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        SearchIcon(color: Theme.text3, size: 15)

                        TextField("Search...", text: $viewModel.searchText)
                            .font(Theme.fontSans(14))
                            .foregroundStyle(Theme.text)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 9)
                    .background(Theme.surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(Theme.border2, lineWidth: 1)
                    }
                    .clipShape(.rect(cornerRadius: Theme.cornerRadius))

                    ScrollView(.horizontal) {
                        HStack(spacing: 6) {
                            ForEach(viewModel.filters, id: \.self) { filter in
                                ChipView(label: filter, isActive: viewModel.selectedFilter == filter, isSmall: true) {
                                    viewModel.selectedFilter = filter
                                }
                            }
                        }
                        .padding(.bottom, 2)
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, 10)

                Rectangle()
                    .fill(Theme.border)
                    .frame(height: 1)

                if viewModel.isLoading {
                    VStack(spacing: 8) {
                        MonoLabel(text: "Loading library", size: 11, tracking: 1.0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        MonoLabel(text: errorMessage, size: 11, color: Theme.text2, tracking: 0.4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, Theme.horizontalPadding)
                } else if viewModel.filteredExercises.isEmpty {
                    VStack(spacing: 8) {
                        MonoLabel(text: "No movements found", size: 11, color: Theme.text2, tracking: 0.4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, Theme.horizontalPadding)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.filteredExercises, id: \.id) { exercise in
                                LibraryExerciseRow(exercise: exercise) {
                                    showMovement(exercise)
                                }

                                Rectangle()
                                    .fill(Theme.border)
                                    .frame(height: 1)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview("Library") {
    let viewModel = LibraryViewModel(exercises: PreviewExerciseRepository())

    let pushUps = Exercise()
    pushUps.name = "Push-Ups"
    pushUps.primaryMuscle = "Chest"
    pushUps.equipment = ["None"]

    let splitSquats = Exercise()
    splitSquats.name = "Bulgarian Split Squats"
    splitSquats.primaryMuscle = "Quads"
    splitSquats.equipment = ["None"]

    viewModel.allExercises = [pushUps, splitSquats]

    return LibraryView(
        viewModel: viewModel,
        showMovement: { _ in }
    )
    .preferredColorScheme(.dark)
}
