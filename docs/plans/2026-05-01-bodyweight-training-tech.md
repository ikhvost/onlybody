# OnlyBody — Technical Plan

**Date:** 2026-05-01
**Platform:** iOS 26.0+
**Language:** Swift 6.2, strict concurrency
**Frameworks:** SwiftUI + SwiftData (on-device only, no CloudKit)
**Status:** MVP — Approved
**Principle:** Frequent future changes expected — loose coupling, high cohesion throughout

---

## 1. Architecture Principles

```
View ──reads──> ViewModel (@Observable @MainActor) ──calls──> Repository (protocol) ──impl──> SwiftDataRepository
```

- **Views** — pure layout only, no business logic, no `@Query`, no `ModelContext`. Replaceable without touching logic.
- **ViewModels** — `@Observable @MainActor`, holds all screen state and logic. Testable with mock repositories. No ViewModel-to-ViewModel dependencies.
- **Repositories** — protocols only. Swap implementations (SwiftData → anything) without touching views or view models.
- **Services** — pure structs, no SwiftUI, no SwiftData. `SmartWorkoutGenerator`, `StreakCalculator`, `RestTimer`. Fully unit-testable.
- **Theme.swift** — single source of truth for all design tokens. Never hardcode colors, font sizes, or spacing.

---

## 2. Project Structure

```
BodyweightApp/
├── App/
│   ├── BodyweightApp.swift                    # @main entry, ModelContainer, root view
│   └── AppTabView.swift                       # Custom tab container (NOT SwiftUI TabView)
├── Models/                                    # SwiftData models, one type per file
│   ├── Exercise.swift
│   ├── Workout.swift
│   ├── WorkoutItem.swift
│   ├── Session.swift
│   └── SessionItem.swift
├── Data/
│   ├── Repositories/
│   │   ├── ExerciseRepository.swift           # Protocol
│   │   ├── WorkoutRepository.swift            # Protocol
│   │   ├── SessionRepository.swift            # Protocol
│   │   ├── SwiftDataExerciseRepository.swift
│   │   ├── SwiftDataWorkoutRepository.swift
│   │   └── SwiftDataSessionRepository.swift
│   └── Seed/
│       ├── SeedData.json
│       └── SeedManager.swift
├── Services/
│   ├── SmartWorkoutGenerator.swift            # pure struct
│   ├── StreakCalculator.swift                 # pure: [Session] → streak stats
│   └── RestTimer.swift                        # @Observable @MainActor
├── ViewModels/                                # @Observable @MainActor, one per screen
│   ├── TrainViewModel.swift
│   ├── MusclePickerViewModel.swift
│   ├── SessionBuilderViewModel.swift
│   ├── ActiveWorkoutViewModel.swift
│   ├── LogViewModel.swift
│   ├── SessionDetailViewModel.swift
│   ├── LibraryViewModel.swift
│   ├── MovementDetailViewModel.swift
│   ├── CustomExerciseViewModel.swift
│   └── StreakViewModel.swift
├── Views/
│   ├── Train/
│   │   ├── TrainView.swift
│   │   ├── MusclePickerView.swift
│   │   ├── SessionBuilderView.swift
│   │   └── ActiveWorkoutView.swift
│   ├── Log/
│   │   ├── LogView.swift
│   │   └── SessionDetailView.swift
│   └── Library/
│       ├── LibraryView.swift
│       ├── MovementDetailView.swift
│       └── CustomExerciseForm.swift
├── Shared/
│   ├── Theme/
│   │   └── Theme.swift                        # Design tokens: colors, fonts, spacing
│   ├── Icons/
│   │   └── AppIcons.swift                     # Custom Shape/Path icons — NOT SF Symbols
│   └── Components/
│       ├── MonoLabel.swift
│       ├── PrimaryButton.swift
│       ├── GhostButton.swift
│       ├── ChipView.swift
│       ├── StepperView.swift
│       ├── SetTrackerView.swift
│       ├── NavBarView.swift
│       ├── ExerciseRow.swift
│       └── ExercisePickerView.swift
├── Resources/
│   └── Assets.xcassets/
└── Tests/
    ├── ServicesTests/
    │   ├── SmartWorkoutGeneratorTests.swift
    │   ├── StreakCalculatorTests.swift
    │   └── RestTimerTests.swift
    └── ViewModelsTests/
        ├── TrainViewModelTests.swift
        ├── SessionBuilderViewModelTests.swift
        └── ActiveWorkoutViewModelTests.swift
```

Zero third-party dependencies.

---

## 3. Data Model (SwiftData — On-Device Only)

```swift
@Model final class Exercise {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var primaryMuscle: String = ""              // "Chest","Back","Shoulders","Arms","Core","Quads","Glutes","Hamstrings","Calves","Full Body","Upper","Lower"
    var secondaryMuscles: [String] = []
    var equipment: [String] = []               // "None","Dumbbells","Pull-up Bar","Resistance Bands","Kettlebell","Barbell"
    var frequencyPreference: String = "normal" // "normal"|"more"|"less"|"never"
    var isCustom: Bool = false
    var createdAt: Date = .now

    @Relationship(deleteRule: .nullify) var workoutItems: [WorkoutItem]?
}

@Model final class Workout {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var mode: String = "smart"                 // "smart"|"manual"
    var targetMuscleGroups: [String] = []      // used in Smart pick mode
    var scheduledDays: [String] = []           // ["Mon","Wed","Fri"]
    var createdAt: Date = .now
    var items: [WorkoutItem]?
}

@Model final class WorkoutItem {
    var id: UUID = UUID()
    var order: Int = 0
    var sets: Int = 3
    var targetReps: Int = 12
    var restSeconds: Int = 45

    @Relationship var exercise: Exercise?
    @Relationship(inverse: \Workout.items) var workout: Workout?
}

@Model final class Session {
    @Attribute(.unique) var id: UUID = UUID()
    var date: Date = .now
    var durationSeconds: Int = 0
    var caloriesBurned: Int? = nil
    var workoutName: String = ""               // snapshot — survives workout deletion
    var items: [SessionItem]?
}

@Model final class SessionItem {
    var id: UUID = UUID()
    var order: Int = 0
    var exerciseName: String = ""              // snapshot
    var plannedSets: Int = 3
    var plannedReps: Int = 12
    var setReps: [Int] = []                    // actual reps per completed set; length = completed sets
    var weightKg: Double? = nil                // "Added kg" stepper value (step: 2.5)
}
```

Key decisions:
- `Exercise.primaryMuscle` + `secondaryMuscles` split matches the Movement Detail screen display (PRIMARY MUSCLE / SECONDARY sections)
- `Exercise.frequencyPreference` drives Smart pick weighting ("more" = picked first, "never" = excluded)
- `Workout.mode` replaces old `type` ("smart"|"manual" matches the UI toggle label "Smart pick / I choose")
- `Workout.scheduledDays` powers the day strip and today callout on the Train screen
- `Session.caloriesBurned` shown in Log and Session Detail screens
- `SessionItem.setReps` (array) replaces scalar `actualReps` — needed for per-set breakdown in SessionDetailView
- `SessionItem.weightKg` renamed from `weightUsed` to match UI label "ADDED KG"
- No Streak model — streak stats (current/longest/total) computed from `[Session]` by `StreakCalculator`
- `youtubeURL` deferred — design shows a muscle diagram placeholder, not video

---

## 4. Repositories (Protocols + SwiftData Implementations)

```swift
protocol ExerciseRepository: Sendable {
    func allExercises() async throws -> [Exercise]
    func exercises(primaryMuscle: String) async throws -> [Exercise]
    func exercises(matching name: String) async throws -> [Exercise]
    func save(_ exercise: Exercise) async throws
    func delete(_ exercise: Exercise) async throws
}

protocol WorkoutRepository: Sendable {
    func allWorkouts() async throws -> [Workout]
    func save(_ workout: Workout) async throws
    func delete(_ workout: Workout) async throws
}

protocol SessionRepository: Sendable {
    func allSessions() async throws -> [Session]
    func recentSessions(limit: Int) async throws -> [Session]
    func save(_ session: Session) async throws
}
```

Concrete `SwiftData*Repository` classes use `ModelContext` internally. ViewModels depend on protocols — enabling mock repositories in tests.

---

## 5. App Entry Point

```swift
@main
struct BodyweightApp: App {
    let container: ModelContainer
    let repositories: Repositories

    init() {
        do {
            container = try ModelContainer(for:
                Exercise.self, Workout.self, WorkoutItem.self,
                Session.self, SessionItem.self
            )
            let context = container.mainContext
            repositories = Repositories(
                exercises: SwiftDataExerciseRepository(context: context),
                workouts: SwiftDataWorkoutRepository(context: context),
                sessions: SwiftDataSessionRepository(context: context)
            )
        } catch { fatalError("ModelContainer failed: \(error)") }
    }

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .modelContainer(container)
                .environment(repositories)
                .task { await SeedManager.seedIfNeeded(context: container.mainContext) }
        }
    }
}

struct Repositories {
    let exercises: ExerciseRepository
    let workouts: WorkoutRepository
    let sessions: SessionRepository
}
```

No CloudKit — no `cloudKitContainerIdentifier`.

---

## 6. Navigation Architecture

Custom tab navigation — **not** SwiftUI `TabView`.

```swift
enum AppTab: String, CaseIterable { case train, log, library }

@MainActor @Observable final class AppTabViewModel {
    var selectedTab: AppTab = .train
}
```

```
AppTabView
├── Tab .train   → NavigationStack → TrainView
│   ├── navigationDestination → MusclePickerView
│   ├── navigationDestination → SessionBuilderView
│   └── fullScreenCover → ActiveWorkoutView
│
├── Tab .log     → NavigationStack → LogView
│   └── navigationDestination → SessionDetailView
│
└── Tab .library → NavigationStack → LibraryView
    ├── navigationDestination → MovementDetailView
    └── sheet → CustomExerciseForm
```

- `BottomNav` reads `AppTabViewModel` from environment; hides when navigation depth > 0
- `ActiveWorkoutView` is a `fullScreenCover` — no accidental back gesture during workout
- Streak screen pushed via `NavigationStack` from `TrainView` header
- No `NavigationLink` — use `navigationDestination(for:)` exclusively

---

## 7. ViewModel Layer

Each screen has exactly one `@Observable @MainActor` view model. ViewModels receive repository protocols via constructor injection.

```swift
@MainActor @Observable final class TrainViewModel {
    private let workouts: WorkoutRepository
    private let sessions: SessionRepository

    var savedWorkouts: [Workout] = []
    var isLoading = false
    var errorMessage: String?

    init(workouts: WorkoutRepository, sessions: SessionRepository) {
        self.workouts = workouts
        self.sessions = sessions
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            savedWorkouts = try await workouts.allWorkouts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

Views inject the view model via `@Environment` and call lifecycle methods in `.task {}`. Views never import SwiftData.

---

## 8. Smart Workout Generator

```swift
struct SmartWorkoutGenerator {
    struct Config {
        let targetMuscleGroups: [String]
        let durationMinutes: Int
    }

    func generate(config: Config, from exercises: [Exercise]) -> Workout {
        // Exclude exercises with frequencyPreference == "never"
        // Weight "more" exercises first, "less" last
        let pool = exercises
            .filter { $0.frequencyPreference != "never" }
            .filter { config.targetMuscleGroups.contains($0.primaryMuscle) ||
                      !Set($0.secondaryMuscles).isDisjoint(with: Set(config.targetMuscleGroups)) }
            .sorted { a, _ in a.frequencyPreference == "more" }

        var items: [WorkoutItem] = []
        var totalSeconds = 0
        let timeBudget = config.durationMinutes * 60

        for exercise in pool {
            let sets = Int.random(in: 3...4)
            let reps = Int.random(in: 8...15)
            let rest = [30, 45, 60, 90].randomElement()!
            let estDuration = (sets * 30) + ((sets - 1) * rest)  // sets×30s active + rest between

            if totalSeconds + estDuration <= timeBudget || items.isEmpty {
                items.append(WorkoutItem(
                    order: items.count, sets: sets, targetReps: reps,
                    restSeconds: rest, exercise: exercise
                ))
                totalSeconds += estDuration
            }
        }

        guard items.count >= 2 else {
            // Fallback: equipment-free pool
            return generate(config: config, from: exercises.filter { $0.equipment.contains("None") })
        }

        let workout = Workout(
            name: "Smart — \(config.targetMuscleGroups.formatted())",
            mode: "smart"
        )
        workout.targetMuscleGroups = config.targetMuscleGroups
        workout.items = items
        return workout
    }
}
```

Pure struct — no SwiftUI, no SwiftData, fully unit-testable.

---

## 9. Streak Calculator

```swift
struct StreakCalculator {
    struct Stats {
        let current: Int
        let longest: Int
        let total: Int
    }

    func calculate(sessions: [Session], today: Date = .now) -> Stats {
        // Compute current streak, longest streak, total session count
        // from sorted Session.date values
        // A session on consecutive calendar days continues a streak
    }
}
```

No Streak SwiftData model. Stats always in sync with actual session history.

---

## 10. Rest Timer

```swift
@MainActor @Observable final class RestTimer {
    var remainingSeconds: Int = 0
    var isActive: Bool = false
    var nextExerciseName: String = ""

    private var task: Task<Void, Never>?

    func start(seconds: Int, nextExercise: String) {
        remainingSeconds = seconds
        nextExerciseName = nextExercise
        isActive = true
        task?.cancel()
        task = Task {
            for _ in 0..<seconds {
                if Task.isCancelled { return }
                try? await Task.sleep(for: .seconds(1))
                remainingSeconds -= 1
            }
            isActive = false
        }
    }

    func skip() {
        task?.cancel()
        remainingSeconds = 0
        isActive = false
    }
}
```

`@Observable` + `@MainActor` + `Task.sleep(for:)` — no `ObservableObject`, no `@Published`, no `Timer`, no `DispatchQueue`.

---

## 11. Pre-Loaded Exercise Seeding

- `SeedData.json` bundled with exercises matching the new `Exercise` shape (`primaryMuscle`, `secondaryMuscles`, `equipment`, `frequencyPreference`)
- `SeedManager` checks `UserDefaults` flag; imports once on first launch
- `@MainActor` struct using `ModelContext`; called from `App.body.task`

---

## 12. Error Handling

| Scenario | Handling |
|----------|----------|
| SwiftData save failure | Alert via view model `errorMessage` |
| Empty exercise pool for Smart pick | Alert "No exercises match. Try different muscle groups." |
| Seed data missing/corrupt | Alert "Could not load exercise library." |
| No exercises with frequencyPreference != "never" | Fallback to all equipment-free exercises |

---

## 13. Testing Strategy

| Layer | Approach |
|-------|----------|
| Services (`SmartWorkoutGenerator`, `StreakCalculator`, `RestTimer`) | Unit tests — pure logic, no deps |
| ViewModels | Unit tests with mock repositories (protocol conformance) |
| Repositories | Integration tests with in-memory `ModelContainer` |
| Views | SwiftUI Previews + manual testing |
| UI | No UI tests for MVP |
