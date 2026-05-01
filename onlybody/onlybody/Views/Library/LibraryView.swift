import SwiftUI

struct LibraryView: View {
    @Bindable var viewModel: LibraryViewModel

    let makeCustomExerciseViewModel: () -> CustomExerciseViewModel
    let showMovement: (Exercise) -> Void

    @State private var customExerciseViewModel: CustomExerciseViewModel?
    @State private var isPresentingCustomExercise = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: Theme.space8) {
                        MonoLabel(text: "Movement catalog", size: 9, tracking: 1.2)

                        Text("Library")
                            .font(Theme.fontSans(26, .heavy))
                            .tracking(-1)
                            .foregroundStyle(Theme.text)
                    }

                    Spacer(minLength: Theme.space10)

                    Button {
                        customExerciseViewModel = makeCustomExerciseViewModel()
                        isPresentingCustomExercise = true
                    } label: {
                        PlusIcon(color: Theme.accentDark, size: 14)
                            .frame(width: 32, height: 32)
                            .background(Theme.accent)
                            .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add custom exercise")
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.top, Theme.space16)
                .padding(.bottom, Theme.space10)

                VStack(spacing: Theme.space8) {
                    HStack(spacing: Theme.space8) {
                        SearchIcon(color: Theme.text3, size: 15)

                        TextField("Search...", text: $viewModel.searchText)
                            .font(Theme.fontSans(13))
                            .foregroundStyle(Theme.text)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, Theme.space10)
                    .padding(.vertical, 9)
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
                        .padding(.bottom, 2)
                    }
                    .scrollIndicators(.hidden)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, Theme.space10)

                Rectangle()
                    .fill(Theme.border)
                    .frame(height: 1)

                if viewModel.isLoading {
                    VStack(spacing: Theme.space8) {
                        MonoLabel(text: "Loading library", size: 10, tracking: 1.0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: Theme.space8) {
                        MonoLabel(text: errorMessage, size: 10, color: Theme.text2, tracking: 0.4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, Theme.horizontalPadding)
                } else if viewModel.filteredExercises.isEmpty {
                    VStack(spacing: Theme.space8) {
                        MonoLabel(text: "No movements found", size: 10, color: Theme.text2, tracking: 0.4)
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
        .sheet(isPresented: $isPresentingCustomExercise, onDismiss: {
            customExerciseViewModel = nil

            Task {
                await viewModel.load()
            }
        }) {
            if let customExerciseViewModel {
                CustomExerciseForm(viewModel: customExerciseViewModel)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
        }
    }
}

#Preview("Library") {
    let viewModel = LibraryViewModel(exercises: EmptyExerciseRepository())

    let pushUps = Exercise()
    pushUps.name = "Push-Ups"
    pushUps.primaryMuscle = "Chest"
    pushUps.equipment = ["None"]

    let splitSquats = Exercise()
    splitSquats.name = "Bulgarian Split Squats"
    splitSquats.primaryMuscle = "Quads"
    splitSquats.equipment = ["None"]
    splitSquats.isCustom = true

    viewModel.allExercises = [pushUps, splitSquats]

    return LibraryView(
        viewModel: viewModel,
        makeCustomExerciseViewModel: {
            CustomExerciseViewModel(exercises: EmptyExerciseRepository())
        },
        showMovement: { _ in }
    )
    .preferredColorScheme(.dark)
}
