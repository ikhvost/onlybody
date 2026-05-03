# AGENTS.md — OnlyBody (Bodyweight Training App)

## Project Overview

Bodyweight training app for iOS. Single user, on-device data, no CloudKit. The app will evolve significantly — architecture must support frequent change with loose coupling and high cohesion.

---

## Target

- **iOS:** 26.0+
- **Swift:** 6.2, strict concurrency
- **Frameworks:** SwiftUI + SwiftData (on-device only)
- **No third-party dependencies**

## Role

You are a **Senior iOS Engineer**, specializing in SwiftUI, SwiftData, and related frameworks. Interactions and accessibility must follow Apple's HIG. Visuals do not — the design system is fully custom.

---

## Code Philosophy

- **Readable over clever.** Code is read far more than written. Prefer obvious names and explicit control flow over compact or indirect expressions.
- **Easy to change.** Favour small, focused types. A function or view that does one thing is straightforward to replace; a tangled one is not. Flat, deletable code beats deep hierarchies.
- **No premature abstraction.** Introduce a protocol or shared type only when a second concrete use already exists. The repository protocol / preview-repository / mock-repository triad is the model — each layer has a real second implementation.
- **One type, one file.** If a file grows unwieldy, split it. Never nest types or accumulate helpers in one file.

---

## Architecture

```
View ──reads──> ViewModel (@Observable @MainActor) ──calls──> Repository (protocol) ──impl──> SwiftDataRepository
```

### Loose Coupling Rules

- **Views** depend only on their ViewModel — never access repositories or services directly. No `@Query`. No `ModelContext`. No SwiftData imports.
- **ViewModels** depend on repository *protocols* — never on concrete SwiftData types. All screen state and logic. Testable with mock repositories.
- **Repositories** — protocols (`ExerciseRepository`, `WorkoutRepository`, `SessionRepository`) with `SwiftData*` implementations. Swap implementations without touching views or view models.
- **Services** — contain logic that doesn't belong in a ViewModel. Prefer pure structs when there is no mutable state across time (`SmartWorkoutGenerator`, `StreakCalculator`). Use `@MainActor @Observable final class` only when the service owns persistent mutable state (`RestTimer` manages countdown state across view renders). No SwiftData imports in services.
- **Repository injection** — repositories are concrete-typed once at app entry in `BodyweightApp.init()`, then passed through view `init` parameters as protocol types (`any ExerciseRepository`, etc.). ViewModels never see the concrete SwiftData type.
- **No ViewModel-to-ViewModel dependencies.** Pass data through navigation, not shared state.
- **Theme.swift** is the only cross-cutting dependency for views — everything else is injected.

### Preview Repositories

`Shared/Preview/` contains `#if DEBUG`-gated structs (`PreviewWorkoutRepository`, `PreviewExerciseRepository`, `PreviewSessionRepository`) that implement each repository protocol with fixed fixture data. Reads return injected arrays; writes are no-ops. Use these in `#Preview` blocks — never create a live `ModelContainer` in previews.

```swift
#if DEBUG
struct PreviewWorkoutRepository: WorkoutRepository {
    let workouts: [Workout]
    func allWorkouts() async throws -> [Workout] { workouts }
    func workout(by id: UUID) async throws -> Workout? { workouts.first { $0.id == id } }
    func save(_ workout: Workout) async throws {}
    func deleteItems(_ items: [WorkoutItem]) async throws {}
}
#endif
```

### Project structure

> This project uses `PBXFileSystemSynchronizedRootGroup` (Xcode 16+). New files and folders added to the filesystem are automatically tracked by Xcode — no manual `.xcodeproj` edits required.

```
onlybody/                              — source root (PBXFileSystemSynchronizedRootGroup)
├── App/
│   ├── BodyweightApp.swift            — @main entry, ModelContainer, root view
│   ├── AppTab.swift                   — AppTab enum + AppTabViewModel
│   └── AppTabView.swift               — Custom tab container (NOT SwiftUI TabView)
├── Features/                          — View + ViewModel colocated per feature
│   ├── Train/
│   │   ├── TrainViewModel.swift
│   │   ├── TrainView.swift
│   │   ├── TrainRoute.swift
│   │   ├── MusclePickerViewModel.swift
│   │   ├── MusclePickerView.swift
│   │   ├── SessionBuilderViewModel.swift
│   │   ├── SessionBuilderView.swift
│   │   ├── ActiveWorkoutViewModel.swift
│   │   ├── ActiveWorkoutView.swift
│   │   ├── StreakViewModel.swift
│   │   └── StreakView.swift
│   ├── Log/
│   │   ├── LogViewModel.swift
│   │   ├── LogView.swift
│   │   └── SessionDetailView.swift
│   └── Library/
│       ├── LibraryViewModel.swift
│       ├── LibraryView.swift
│       ├── LibraryExerciseRow.swift
│       ├── MovementDetailViewModel.swift
│       ├── MovementDetailView.swift
│       ├── CustomExerciseViewModel.swift
│       └── CustomExerciseForm.swift
├── Core/                              — Infrastructure: repositories, services
│   ├── Repositories/
│   │   ├── ExerciseRepository.swift
│   │   ├── WorkoutRepository.swift
│   │   ├── SessionRepository.swift
│   │   ├── SwiftDataExerciseRepository.swift
│   │   ├── SwiftDataWorkoutRepository.swift
│   │   └── SwiftDataSessionRepository.swift
│   ├── Services/                      — Business logic; structs preferred, class when stateful
│   │   ├── SmartWorkoutGenerator.swift
│   │   ├── StreakCalculator.swift      — [Session] → streak stats (current/longest/total)
│   │   └── RestTimer.swift
├── Models/                            — SwiftData @Model classes, one type per file
│   ├── Exercise.swift
│   ├── Workout.swift
│   ├── WorkoutItem.swift
│   ├── Session.swift
│   └── SessionItem.swift
├── Shared/
│   ├── Theme/
│   │   └── Theme.swift                — Design tokens: colors, fonts, spacing
│   ├── Icons/                         — Canvas-based icon Views (one per file) + AppIcons.swift config
│   ├── Components/                    — Reusable views, no own view models
│   │   ├── MonoLabel.swift
│   │   ├── PrimaryButton.swift
│   │   ├── GhostButton.swift
│   │   ├── ChipView.swift
│   │   ├── StepperView.swift
│   │   ├── SetTrackerView.swift
│   │   ├── NavBarView.swift
│   │   ├── BottomNav.swift
│   │   ├── ExercisePickerView.swift
│   │   ├── CustomBadgeView.swift
│   │   └── FlowLayout.swift
│   ├── Domain/                        — Cross-cutting domain enums and catalogs
│   │   ├── ExerciseCatalog.swift
│   │   ├── ExerciseFrequency.swift
│   │   ├── Weekdays.swift
│   │   └── WorkoutMode.swift
│   └── Preview/                       — Mock repositories for Xcode Previews
├── Resources/
│   ├── Assets.xcassets/
│   ├── Fonts/
│   └── SeedStore/                     — pre-seeded SQLite store bundled with the app
onlybodyTests/                         — test root (PBXFileSystemSynchronizedRootGroup)
├── Features/
│   ├── Train/                         — TrainViewModelTests, ActiveWorkoutViewModelTests, etc.
│   ├── Log/                           — LogViewModelTests
│   └── Library/                       — LibraryViewModelTests, etc.
├── Core/
│   ├── Repositories/                  — SwiftData*RepositoryTests (in-memory ModelContainer)
│   └── Services/                      — SmartWorkoutGeneratorTests, StreakCalculatorTests, etc.
└── Support/                           — Mock repositories, TestError
```

---

## Theme

All design tokens live in `Shared/Theme/Theme.swift`. This is the single source of truth for colors, fonts, and spacing. Never hardcode color literals, font sizes, or padding values in views.

Key constants:
- `Theme.accent` — `#E8A23A`
- `Theme.accentDim`, `Theme.accentDark`
- `Theme.bg`, `Theme.surface`, `Theme.surface2`
- `Theme.text`, `Theme.text2`, `Theme.text3`
- `Theme.border`, `Theme.border2`
- `Theme.danger`, `Theme.iconDim`
- `Theme.fontSans(_ size: CGFloat, _ weight: Font.Weight)` — DM Sans
- `Theme.fontMono(_ size: CGFloat, _ weight: Font.Weight)` — DM Mono
- `Theme.horizontalPadding` — 18
- `Theme.cornerRadius` — 4
- `Theme.chipCornerRadius` — 3

---

## Navigation

Custom tab navigation — do **NOT** use SwiftUI `TabView` or the `Tab` API.

```swift
enum AppTab: String, CaseIterable { case train, log, library }

@MainActor @Observable final class AppTabViewModel {
    var selectedTab: AppTab = .train
}
```

- `AppTabView` manages `selectedTab` and renders the custom `BottomNav`
- Each tab owns its own `NavigationStack` with `navigationDestination(for:)`
- `BottomNav` hides when a sub-screen is pushed (track navigation depth per tab)
- `ActiveWorkoutView` is presented via `fullScreenCover` — prevents accidental back-navigation during a workout
- No `NavigationLink` — use `navigationDestination(for:)` exclusively

---

## Swift Instructions

- `@Observable` classes must be `@MainActor`.
- Never use `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject`.
- Strict concurrency — no `DispatchQueue.main.async()`. Use async/await.
- Prefer Swift-native over Foundation: `replacing("x", with: "y")` over `replacingOccurrences`.
- Modern Foundation: `URL.documentsDirectory`, `appending(path:)`.
- Never C-style formatting: use `Text(value, format: .number.precision(.fractionLength(2)))`.
- Prefer static member lookup: `.circle` over `Circle()`, `.borderedProminent` over `BorderedProminentButtonStyle()`.
- Filter user input with `localizedStandardContains()`, never `contains()`.
- No force unwraps or force `try` unless unrecoverable.
- Never legacy Formatters: `myDate.formatted(date: .abbreviated, time: .shortened)` over `DateFormatter`.
- Never `Task.sleep(nanoseconds:)` — use `Task.sleep(for:)`.

## SwiftUI Instructions

- Use `foregroundStyle()` over `foregroundColor()`.
- Use `clipShape(.rect(cornerRadius:))` over `cornerRadius()`.
- Use `navigationDestination(for:)` with `NavigationStack`. No `NavigationLink`.
- No `ObservableObject` — `@Observable` classes only.
- No single-parameter `onChange()`. Use the two-parameter variant.
- No `onTapGesture()` — use `Button` instead (unless you need tap location).
- No `UIScreen.main.bounds`.
- No `AnyView` unless absolutely required.
- No `GeometryReader` — prefer `containerRelativeFrame()` or `visualEffect()`.
- No view breakup via computed properties — create new `View` structs.
- Use `ImageRenderer` over `UIGraphicsImageRenderer`.
- `ForEach` over enumerated: `ForEach(x.enumerated(), id: \.element.id)` (no `Array()` wrapping).
- Hide indicators: `.scrollIndicators(.hidden)`.
- Use `ScrollPosition` and `defaultScrollAnchor` over `ScrollViewReader`.
- No UIKit colors in SwiftUI.
- **Font sizes:** OnlyBody uses a custom fixed typography scale in `Theme.swift`. Use `Theme.fontSans` and `Theme.fontMono` — NOT Dynamic Type text styles (`.title`, `.body`, etc.).
- **Spacing/padding:** Always use `Theme` spacing constants. Do not call `.padding()` without a value — always reference `Theme.horizontalPadding` or an explicit `Theme` constant.
- **Tab navigation:** Do NOT use SwiftUI `Tab` API or `tabItem()`. Use `AppTabView` with `AppTab` enum. See Navigation section.
- Button with image must include text: `Button("Label", systemImage: "icon", action: ...)` — but prefer custom icon views over SF Symbols.
- **Icons:** Custom icons live in `Shared/Icons/` — one file per icon (e.g. `TrainIcon.swift`, `ChevronIcon.swift`). Each is a `Canvas`-based `View`. Do NOT use SF Symbols. Shared config lives in `AppIcons.swift` (`viewport: CGFloat = 24`, `stroke: StrokeStyle`). Canonical pattern:
  ```swift
  struct FooIcon: View {
      var color: Color = Theme.text
      var size: CGFloat = 20
      var body: some View {
          Canvas { context, canvasSize in
              let scale = canvasSize.width / AppIcons.viewport
              context.scaleBy(x: scale, y: scale)
              context.stroke(path, with: .color(color), style: AppIcons.stroke)
          }
          .frame(width: size, height: size)
      }
  }
  ```

## SwiftData Instructions

- On-device only — `@Attribute(.unique)` is safe and should be used.
- All model properties must have default values OR be optional.
- Relationships must be optional when the related object may be deleted independently.
- Use `@Relationship(deleteRule: .cascade)` when a parent owns its children (e.g. `Workout.items`, `Session.items`). Use `@Relationship(deleteRule: .nullify)` for cross-references where the related object may be deleted independently (e.g. `WorkoutItem.workout` inverse).

- **Seed data**: Exercise catalog is shipped as a pre-populated SQLite store in `Resources/SeedStore/default.store`, copied to Documents on first launch. No runtime JSON parsing or bulk inserts. When exercises change, regenerate with:
  ```bash
  swift run --package-path Scripts/StoreGenerator StoreGenerator \
    onlybody/onlybody/Resources/SeedStore/default.store \
    onlybody/onlybody/Core/Seed/SeedData.json
  ```

## Testing

Framework: **Swift Testing** (`@Test`, `#expect`) — do NOT use XCTest.

```swift
@MainActor
struct FooViewModelTests {
    @Test func someExpectedBehavior() async {
        let repo = MockWorkoutRepository()
        let vm = FooViewModel(workouts: repo)
        await vm.load()
        #expect(vm.workouts.count == 1)
    }
}
```

- Unit-test all Services (pure logic, no dependencies).
- Unit-test all ViewModels using mock repository protocols. Mocks live in `onlybodyTests/Support/` (`MockWorkoutRepository`, `MockExerciseRepository`, `MockSessionRepository`). Each mock has a `shouldThrow` flag and records saved/deleted data for assertion.
- Integration-test repositories with in-memory `ModelContainer` (`ModelConfiguration(isStoredInMemoryOnly: true)`).
- No UI tests for MVP unless required.
- SwiftUI Previews for view iteration.

## Code Quality

- One type per file — no multiple structs/classes/enums in one file.
- Feature-based folder organization.
- Add documentation comments for public interfaces.
- No secrets in the repository.
- If the project uses Localizable.xcstrings, use symbol keys accessed via generated symbols like `Text(.helloWorld)`.

## Linting

- No SwiftLint warnings or errors before committing.

## Xcode MCP (if configured)

Prefer these tools over generic alternatives:
- `DocumentationSearch` — verify API availability before writing code
- `BuildProject` — build after changes
- `GetBuildLog` — inspect errors
- `RenderPreview` — verify views via Xcode Previews
- `ExecuteSnippet` — test code in source context
- `XcodeRead`, `XcodeWrite`, `XcodeUpdate` — prefer for Xcode project files
