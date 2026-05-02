import SwiftUI

struct AppTabView: View {
    private let repositories: Repositories

    @State private var tabViewModel = AppTabViewModel()
    @State private var trainViewModel: TrainViewModel
    @State private var libraryViewModel: LibraryViewModel
    @State private var trainPath = NavigationPath()
    @State private var logPath = NavigationPath()
    @State private var libraryPath = NavigationPath()
    @State private var activeWorkoutID: UUID?
    @State private var activeWorkoutName: String = ""

    init(repositories: Repositories) {
        self.repositories = repositories
        _trainViewModel = State(initialValue: TrainViewModel(workouts: repositories.workouts, sessions: repositories.sessions))
        _libraryViewModel = State(initialValue: LibraryViewModel(exercises: repositories.exercises))
    }

    private var showsBottomNav: Bool {
        switch tabViewModel.selectedTab {
        case .train:
            trainPath.isEmpty
        case .log:
            logPath.isEmpty
        case .library:
            libraryPath.isEmpty
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if showsBottomNav {
                BottomNav(
                    selectedTab: tabViewModel.selectedTab,
                    setTab: { tabViewModel.selectedTab = $0 }
                )
            }
        }
        .background(Theme.bg)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var tabContent: some View {
        ZStack {
            tabStack(.train, path: $trainPath) {
                TrainView(
                    viewModel: trainViewModel,
                    showMusclePicker: {
                        trainPath.append(TrainRoute.musclePicker)
                    },
                    showSessionBuilder: { workoutID in
                        trainPath.append(TrainRoute.sessionBuilder(workoutID: workoutID))
                    },
                    showStreak: {
                        trainPath.append(TrainRoute.streak)
                    },
                    onStartWorkout: { id, name in
                        activeWorkoutID = id
                        activeWorkoutName = name
                    }
                )
                .navigationDestination(for: TrainRoute.self) { route in
                    switch route {
                    case .musclePicker:
                        MusclePickerView(
                            viewModel: MusclePickerViewModel(),
                            onBuild: { selected in
                                trainPath.append(TrainRoute.sessionBuilder(
                                    workoutID: nil,
                                    targetMuscleGroups: selected
                                ))
                            },
                            onSkip: {
                                trainPath.append(TrainRoute.sessionBuilder(
                                    workoutID: nil,
                                    targetMuscleGroups: []
                                ))
                            }
                        )
                    case .sessionBuilder(let workoutID, let targetMuscleGroups):
                        let workout = workoutID.flatMap { id in
                            trainViewModel.workouts.first { $0.id == id }
                        }
                        SessionBuilderView(
                            viewModel: SessionBuilderViewModel(
                                workouts: repositories.workouts,
                                exercises: repositories.exercises,
                                workout: workout,
                                targetMuscleGroups: targetMuscleGroups
                            )
                        )
                    case .streak:
                        StreakView()
                    }
                }
            }
            .onChange(of: trainPath) { _, _ in
                if trainPath.isEmpty {
                    Task { await trainViewModel.load() }
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { activeWorkoutID != nil },
                set: { if !$0 { activeWorkoutID = nil } }
            )) {
                ActiveWorkoutView(
                    workoutName: activeWorkoutName,
                    onEnd: {
                        activeWorkoutID = nil
                    }
                )
            }

            tabStack(.log, path: $logPath) {
                LogView()
            }

            tabStack(.library, path: $libraryPath) {
                LibraryView(
                    viewModel: libraryViewModel,
                    makeCustomExerciseViewModel: {
                        CustomExerciseViewModel(exercises: repositories.exercises)
                    },
                    showMovement: {
                        libraryPath.append(LibraryRoute.movementDetail($0.id))
                    }
                )
                .navigationDestination(for: LibraryRoute.self) { route in
                    switch route {
                    case .movementDetail(let exerciseID):
                        if let exercise = libraryViewModel.exercise(id: exerciseID) {
                            MovementDetailView(
                                viewModel: MovementDetailViewModel(
                                    exercise: exercise,
                                    exercises: repositories.exercises
                                )
                            )
                        } else {
                            ZStack {
                                Theme.bg.ignoresSafeArea()

                                MonoLabel(
                                    text: "Movement unavailable",
                                    size: 10,
                                    color: Theme.text2,
                                    tracking: 0.4
                                )
                            }
                        }
                    }
                }
        }
        }
    }

    private func tabStack<Content: View>(
        _ tab: AppTab,
        path: Binding<NavigationPath>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack(path: path) {
            content()
                .toolbar(.hidden, for: .navigationBar)
        }
        .opacity(tabViewModel.selectedTab == tab ? 1 : 0)
        .allowsHitTesting(tabViewModel.selectedTab == tab)
        .accessibilityHidden(tabViewModel.selectedTab != tab)
    }
}
