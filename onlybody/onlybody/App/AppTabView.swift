import SwiftUI

struct AppTabView: View {
    private let exercises: any ExerciseRepository
    private let workouts: any WorkoutRepository
    private let sessions: any SessionRepository

    @State private var selectedTab: AppTab = .train
    @State private var trainViewModel: TrainViewModel
    @State private var logViewModel: LogViewModel
    @State private var libraryViewModel: LibraryViewModel
    @State private var trainPath = NavigationPath()
    @State private var logPath = NavigationPath()
    @State private var libraryPath = NavigationPath()
    @State private var activeWorkoutViewModel: ActiveWorkoutViewModel?

    init(
        exercises: any ExerciseRepository,
        workouts: any WorkoutRepository,
        sessions: any SessionRepository
    ) {
        self.exercises = exercises
        self.workouts = workouts
        self.sessions = sessions
        _trainViewModel = State(initialValue: TrainViewModel(workouts: workouts))
        _logViewModel = State(initialValue: LogViewModel(sessions: sessions))
        _libraryViewModel = State(initialValue: LibraryViewModel(exercises: exercises))
    }

    private var showsBottomNav: Bool {
        switch selectedTab {
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
                    selectedTab: selectedTab,
                    setTab: { selectedTab = $0 }
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
                    onStartWorkout: { id in
                        activeWorkoutViewModel = ActiveWorkoutViewModel(
                            workouts: workouts,
                            sessions: sessions,
                            workoutId: id
                        )
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
                                workouts: workouts,
                                exercises: exercises,
                                workout: workout,
                                targetMuscleGroups: targetMuscleGroups
                            )
                        )
                    case .streak:
                        StreakView(viewModel: StreakViewModel(sessions: sessions))
                    }
                }
            }
            .onChange(of: trainPath) { _, _ in
                if trainPath.isEmpty {
                    Task { await trainViewModel.load() }
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { activeWorkoutViewModel != nil },
                set: { if !$0 { dismissActiveWorkout() } }
            )) {
                if let viewModel = activeWorkoutViewModel {
                    ActiveWorkoutView(viewModel: viewModel, onEnd: {
                        dismissActiveWorkout()
                    })
                }
            }

            tabStack(.log, path: $logPath) {
                LogView(
                    viewModel: logViewModel,
                    showSessionDetail: { sessionID in
                        logPath.append(sessionID)
                    }
                )
                .navigationDestination(for: UUID.self) { sessionID in
                    if let session = logViewModel.sessions.first(where: { $0.id == sessionID }) {
                        SessionDetailView(session: session)
                    } else {
                        ZStack {
                            Theme.bg.ignoresSafeArea()
                            MonoLabel(
                                text: "Session unavailable",
                                size: 10,
                                color: Theme.text2,
                                tracking: 0.4
                            )
                        }
                    }
                }
            }
            .onChange(of: logPath) { _, _ in
                if logPath.isEmpty {
                    Task { await logViewModel.load() }
                }
            }

            tabStack(.library, path: $libraryPath) {
                LibraryView(
                    viewModel: libraryViewModel,
                    makeCustomExerciseViewModel: {
                        CustomExerciseViewModel(exercises: exercises)
                    },
                    showMovement: {
                        libraryPath.append($0.id)
                    }
                )
                .navigationDestination(for: UUID.self) { exerciseID in
                    if let exercise = libraryViewModel.exercise(id: exerciseID) {
                        MovementDetailView(
                            viewModel: MovementDetailViewModel(
                                exercise: exercise,
                                exercises: exercises
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

    private func dismissActiveWorkout() {
        activeWorkoutViewModel?.cleanup()
        activeWorkoutViewModel = nil
        Task { await trainViewModel.load() }
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
        .opacity(selectedTab == tab ? 1 : 0)
        .allowsHitTesting(selectedTab == tab)
        .accessibilityHidden(selectedTab != tab)
    }
}
