# OnlyBody — Implementation Task Breakdown

**Date:** 2026-05-01
**Status:** MVP — Approved
**Total Tasks:** 18

Each task is a small, independently implementable unit. A dedicated agent implements each one in order. Tasks within the same dependency tier can be parallelized.

---

## Dependency Order

```
Task 01 (Foundation)
  └─ Task 02 (Models)
       └─ Task 03 (Repositories)
            ├─ Task 04 (Seed Data)
            └─ Task 05 (Services)
                 └─ Task 06 (Shared Components)
                      └─ Task 07 (App Entry & Navigation)
                           ├─ Task 08 (Train Screen)
                           │    ├─ Task 09 (Muscle Picker)
                           │    └─ Task 10 (Session Builder)
                           │         └─ Task 11 (Active Workout)
                           ├─ Task 12 (Log Screen)
                           │    └─ Task 13 (Session Detail)
                           └─ Task 14 (Library Screen)
                                ├─ Task 15 (Movement Detail)
                                └─ Task 16 (Custom Exercise Form)
                 └─ Task 17 (Streak Screen)
Task 18 (Tests) — after all above
```

---

## Task 01 — Project Foundation & Design System

**Scope:** Xcode project skeleton, `Theme.swift`, `AppIcons.swift`.

**Files to create:**
- `BodyweightApp/` (Xcode project: iOS 26.0+, Swift 6.2, strict concurrency `SWIFT_STRICT_CONCURRENCY = complete`)
- `Shared/Theme/Theme.swift`
- `Shared/Icons/AppIcons.swift`
- `Resources/Assets.xcassets/`
- `Info.plist`: `UIUserInterfaceStyle = Dark`

**Theme.swift — complete token set:**

```swift
enum Theme {
    static let accent     = Color(red: 232/255, green: 162/255, blue:  58/255)
    static let accentDim  = Color(red: 232/255, green: 162/255, blue:  58/255, opacity: 0.13)
    static let accentDark = Color(red:  12/255, green:  12/255, blue:  11/255)
    static let bg         = Color(red:  12/255, green:  12/255, blue:  11/255)
    static let surface    = Color(red:  22/255, green:  22/255, blue:  20/255)
    static let surface2   = Color(red:  30/255, green:  30/255, blue:  27/255)
    static let border     = Color(red: 255/255, green: 250/255, blue: 230/255, opacity: 0.07)
    static let border2    = Color(red: 255/255, green: 250/255, blue: 230/255, opacity: 0.13)
    static let text       = Color(red: 245/255, green: 240/255, blue: 232/255)
    static let text2      = Color(red: 245/255, green: 240/255, blue: 232/255, opacity: 0.50)
    static let text3      = Color(red: 245/255, green: 240/255, blue: 232/255, opacity: 0.24)
    static let danger     = Color(red: 224/255, green:  90/255, blue:  78/255)
    static let success    = Color(red:  76/255, green: 175/255, blue: 110/255)

    static func fontSans(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom("DMSans", size: size).weight(weight)
    }
    static func fontMono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom("DMMono", size: size).weight(weight)
    }

    static let horizontalPadding: CGFloat = 18
    static let cornerRadius:      CGFloat =  4
    static let chipCornerRadius:  CGFloat =  3
}
```

Note: Exact PostScript names for DM Sans / DM Mono must be verified against the bundled font files. Use `CTFont` inspection or a font viewer if unsure.

**AppIcons.swift — 13 custom icons:**

Each icon is a `struct XxxIcon: View` with a `color: Color` parameter (default `Theme.text`) and a `size: CGFloat` parameter (default 20). All use `strokeWidth: 1.8`, `strokeLinecap: .square`, `strokeLineJoin: .miter`. Paths mirror the HTML prototype's SVG geometry exactly.

| Icon | View name | Geometry |
|---|---|---|
| Tab: Train | `TrainIcon` | Two small rects top row + one wide rect below |
| Tab: Log | `LogIcon` | Calendar rect with horizontal lines + tick marks |
| Tab: Library | `LibraryIcon` | Circle with inner `+` crosshair |
| Navigation back | `BackIcon` | Left chevron `‹` (path `M16 4 L8 12 L16 20`) |
| Navigation forward | `FwdIcon` | Right chevron `›` (path `M8 4 L16 12 L8 20`) |
| Add / plus | `PlusIcon` | `+` cross (paths `M12 4v16` + `M4 12h16`) |
| Start | `PlayIcon` | Solid right-pointing triangle (fill, no stroke) |
| Edit | `EditIcon` | Pencil path |
| Remove | `RemoveIcon` | Square outline with `×` inside |
| Complete | `CheckIcon` | Checkmark `✓` (strokeWidth 2.5) |
| Search | `SearchIcon` | Circle + diagonal line |
| Chevron (list rows) | `ChevronIcon` | Single right chevron (`M9 4 L17 12 L9 20`) |
| Drag handle | `DragIcon` | 6-dot 2×3 grid (filled rects, no stroke) |

All icons render via SwiftUI `Canvas` or `Path`. `DragIcon` uses `fill(color)` on rectangles. `PlayIcon` uses `fill(color)` with no stroke on a polygon path.

**Verification:** SwiftUI `#Preview` in each file renders all tokens and all icon variants. Project builds with zero warnings.

---

## Task 02 — SwiftData Models

**Scope:** Five `@Model` classes. No UI. No business logic.

**Files:**
- `Models/Exercise.swift`
- `Models/Workout.swift`
- `Models/WorkoutItem.swift`
- `Models/Session.swift`
- `Models/SessionItem.swift`

**Exact model definitions:**

```swift
@Model final class Exercise {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var primaryMuscle: String = ""      // "Chest"|"Back"|"Shoulders"|"Arms"|"Core"|"Quads"|"Glutes"|"Hamstrings"|"Calves"|"Full Body"|"Upper"|"Lower"
    var secondaryMuscles: [String] = []
    var equipment: [String] = []        // "None"|"Dumbbells"|"Pull-up Bar"|"Resistance Bands"|"Kettlebell"|"Barbell"
    var frequencyPreference: String = "normal"  // "normal"|"more"|"less"|"never"
    var isCustom: Bool = false
    var createdAt: Date = .now
    @Relationship(deleteRule: .nullify) var workoutItems: [WorkoutItem]? = nil
}

@Model final class Workout {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String = ""
    var mode: String = "smart"          // "smart"|"manual"
    var targetMuscleGroups: [String] = []
    var scheduledDays: [String] = []    // ["Mon","Wed","Fri"]
    var createdAt: Date = .now
    var items: [WorkoutItem]? = nil
}

@Model final class WorkoutItem {
    var id: UUID = UUID()
    var order: Int = 0
    var sets: Int = 3
    var targetReps: Int = 12
    var restSeconds: Int = 45
    @Relationship var exercise: Exercise? = nil
    @Relationship(deleteRule: .nullify, inverse: \Workout.items) var workout: Workout? = nil
}

@Model final class Session {
    @Attribute(.unique) var id: UUID = UUID()
    var date: Date = .now
    var durationSeconds: Int = 0
    var caloriesBurned: Int? = nil
    var workoutName: String = ""        // snapshot — survives workout deletion
    var items: [SessionItem]? = nil
}

@Model final class SessionItem {
    var id: UUID = UUID()
    var order: Int = 0
    var exerciseName: String = ""       // snapshot
    var plannedSets: Int = 3
    var plannedReps: Int = 12
    var setReps: [Int] = []             // actual reps per completed set; length = completed sets
    var weightKg: Double? = nil         // "Added kg" value (step: 2.5)
}
```

**Rules:**
- All properties have default values or are optional — no custom init required.
- `@Attribute(.unique)` only on root-model `id` fields.
- `deleteRule: .nullify` prevents cascade; relationships to WorkoutItem from both Exercise and Workout are nullified on deletion.
- No SwiftUI or business logic in model files.

**Verification:** In-memory `ModelContainer(for: Exercise.self, ...)` insert/fetch round-trip test for each model (see Task 18).

---

## Task 03 — Repository Protocols & SwiftData Implementations

**Scope:** 3 protocols + 3 SwiftData implementations + `Repositories` DI struct.

**Files:**
- `Data/Repositories/ExerciseRepository.swift` — protocol only
- `Data/Repositories/WorkoutRepository.swift` — protocol only
- `Data/Repositories/SessionRepository.swift` — protocol only
- `Data/Repositories/SwiftDataExerciseRepository.swift`
- `Data/Repositories/SwiftDataWorkoutRepository.swift`
- `Data/Repositories/SwiftDataSessionRepository.swift`

**Protocols:**

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

**SwiftData implementations:**
- `@MainActor final class SwiftDataExerciseRepository: ExerciseRepository`
- `ModelContext` injected via `init(context: ModelContext)`
- `allExercises()` → `FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.name)])`
- `exercises(primaryMuscle:)` → predicate `$0.primaryMuscle == muscle`
- `exercises(matching:)` → `$0.name.localizedStandardContains(name)` — never `contains()`
- `save(_:)` → `context.insert(obj); try context.save()` (insert is idempotent for existing tracked objects)
- `delete(_:)` → `context.delete(obj); try context.save()`
- `recentSessions(limit:)` → `FetchDescriptor` with `fetchLimit: limit`, sorted by `.date` descending

**`Repositories` DI struct:**

```swift
struct Repositories: EnvironmentKey {
    static let defaultValue = Repositories(
        exercises: fatalErrorRepository(),
        workouts: fatalErrorRepository(),
        sessions: fatalErrorRepository()
    )
    let exercises: any ExerciseRepository
    let workouts: any WorkoutRepository
    let sessions: any SessionRepository
}

extension EnvironmentValues {
    var repositories: Repositories {
        get { self[Repositories.self] }
        set { self[Repositories.self] = newValue }
    }
}
```

**Verification:** Integration tests with `ModelConfiguration(isStoredInMemoryOnly: true)` (Task 18).

---

## Task 04 — Seed Data

**Scope:** `SeedData.json` with 25+ exercises + `SeedManager` for one-shot first-launch import.

**Files:**
- `Data/Seed/SeedData.json`
- `Data/Seed/SeedManager.swift`

**SeedData.json shape:**

```json
[
  {
    "name": "Push-Ups",
    "primaryMuscle": "Chest",
    "secondaryMuscles": ["Triceps", "Shoulders"],
    "equipment": ["None"],
    "frequencyPreference": "normal",
    "isCustom": false
  }
]
```

**Required coverage (≥2 per muscle group):**

| primaryMuscle | Exercises |
|---|---|
| Chest | Push-Ups, Archer Push-Ups, Wide Push-Ups, Diamond Push-Ups |
| Back | Pull-Ups, Chin-Ups, Inverted Rows, Muscle-Ups |
| Shoulders | Pike Push-Ups, Wall Handstand Push-Ups, Shoulder Taps |
| Arms | Dips, Tricep Dips |
| Core | Plank, Hollow Body Hold, Leg Raises, Bicycle Crunches |
| Quads | Squats, Lunges, Bulgarian Split Squats, Jump Squats |
| Glutes | Glute Bridge, Hip Thrusts, Donkey Kicks |
| Hamstrings | Nordic Curls, Single-Leg Romanian Deadlift |
| Calves | Calf Raises, Single-Leg Calf Raises |
| Full Body | Burpees, Mountain Climbers |

`equipment` values must be from: `["None","Dumbbells","Pull-up Bar","Resistance Bands","Kettlebell","Barbell"]`.

**SeedManager.swift:**

```swift
@MainActor struct SeedManager {
    private static let key = "didSeedExercises"

    static func seedIfNeeded(context: ModelContext) async {
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        guard let url = Bundle.main.url(forResource: "SeedData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let seeds = try? JSONDecoder().decode([ExerciseSeed].self, from: data)
        else { return }

        for seed in seeds {
            let ex = Exercise()
            ex.name = seed.name
            ex.primaryMuscle = seed.primaryMuscle
            ex.secondaryMuscles = seed.secondaryMuscles
            ex.equipment = seed.equipment
            ex.frequencyPreference = seed.frequencyPreference
            ex.isCustom = seed.isCustom
            context.insert(ex)
        }
        try? context.save()
        UserDefaults.standard.set(true, forKey: key)
    }

    private struct ExerciseSeed: Decodable {
        let name: String
        let primaryMuscle: String
        let secondaryMuscles: [String]
        let equipment: [String]
        let frequencyPreference: String
        let isCustom: Bool
    }
}
```

**Verification:** Delete app → reinstall → Library shows 25+ exercises. Re-launch → no duplicates.

---

## Task 05 — Services

**Scope:** Three service types. Zero SwiftUI imports. Zero SwiftData in logic (except receiving `[Session]`/`[Exercise]` value arrays as parameters).

**Files:**
- `Services/StreakCalculator.swift`
- `Services/SmartWorkoutGenerator.swift`
- `Services/RestTimer.swift`

### StreakCalculator

```swift
struct StreakCalculator {
    struct Stats { let current: Int; let longest: Int; let total: Int }

    func calculate(sessions: [Session], today: Date = .now) -> Stats
}
```

**Algorithm:**
1. Extract calendar day (`Calendar.current.startOfDay(for: session.date)`) for each session.
2. Deduplicate, sort ascending.
3. **Current**: walk backward from `startOfDay(for: today)`. Count consecutive days (each one day before the previous). Stop at first gap.
4. **Longest**: single pass, track run length vs. max.
5. **Total**: `sessions.count` (not deduplicated days).

Edge cases: empty → `Stats(0,0,0)`. Session yesterday only → `current = 0`.

### SmartWorkoutGenerator

Returns `[GeneratedItem]` (value type) — caller maps to SwiftData objects.

```swift
struct SmartWorkoutGenerator {
    struct Config { let targetMuscleGroups: [String]; let durationMinutes: Int }

    struct GeneratedItem {
        let exercise: Exercise
        let sets: Int
        let targetReps: Int
        let restSeconds: Int
    }

    func generate(config: Config, from exercises: [Exercise]) -> [GeneratedItem]
}
```

**Algorithm:**
1. Filter: `frequencyPreference != "never"`.
2. Filter: `primaryMuscle ∈ targets || !Set(secondaryMuscles).isDisjoint(with: Set(targets))`.
3. Sort: `"more"` first → `"normal"` → `"less"`.
4. Time-budget loop:
   - `sets = Int.random(in: 3...4)`, `reps = Int.random(in: 8...15)`, `rest = [30,45,60,90].randomElement()!`
   - `estDuration = sets * 30 + (sets - 1) * rest`
   - Add if `totalSeconds + estDuration ≤ budget || items.isEmpty`
5. If `items.count < 2`: fallback — recurse with `exercises.filter { $0.equipment.contains("None") }`.

### RestTimer

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
        task = Task { [weak self] in
            for _ in 0..<seconds {
                if Task.isCancelled { return }
                try? await Task.sleep(for: .seconds(1))
                guard let self else { return }
                self.remainingSeconds -= 1
            }
            self?.isActive = false
        }
    }

    func skip() { task?.cancel(); remainingSeconds = 0; isActive = false }
}
```

Uses `Task.sleep(for: .seconds(1))` — no `Timer`, no `DispatchQueue`.

**Verification:** Unit tests for all three (Task 18).

---

## Task 06 — Shared UI Components

**Scope:** 9 reusable SwiftUI views. No own ViewModels. No business logic. No SwiftData imports.

**Files:**
- `Shared/Components/MonoLabel.swift`
- `Shared/Components/PrimaryButton.swift`
- `Shared/Components/GhostButton.swift`
- `Shared/Components/ChipView.swift`
- `Shared/Components/StepperView.swift`
- `Shared/Components/SetTrackerView.swift`
- `Shared/Components/NavBarView.swift`
- `Shared/Components/ExerciseRow.swift`
- `Shared/Components/ExercisePickerView.swift`

### MonoLabel

```swift
struct MonoLabel: View {
    let text: String
    var size: CGFloat = 10
    var color: Color = Theme.text3
    var tracking: CGFloat = 1.0
    // body: Text(text).font(Theme.fontMono(size)).foregroundStyle(color).tracking(tracking).textCase(.uppercase)
}
```

### PrimaryButton

Full-width, `padding(.vertical, 15)`, `clipShape(.rect(cornerRadius: Theme.cornerRadius))`.
- Enabled: `background(Theme.accent)`, `foregroundStyle(Theme.accentDark)`, `font(Theme.fontSans(15, .bold))`
- Disabled: `background(Theme.surface2)`, `foregroundStyle(Theme.text3)`

Use `Button` — NOT `onTapGesture`. `.animation(.easeInOut(duration: 0.15), value: isDisabled)`.

### GhostButton

`padding(.horizontal, 14).padding(.vertical, 8)`. Overlay: `RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.border2)`. `foregroundStyle(Theme.text2)`. `font(Theme.fontSans(13, .medium))`.

### ChipView

Active: `background(Theme.accent)`, border `Theme.accent`, `foregroundStyle(Theme.accentDark)`.
Inactive: `background(Theme.surface2)`, border `Theme.border2`, `foregroundStyle(Theme.text2)`.
Small (`isSmall: true`): `padding(.horizontal, 10).padding(.vertical, 5)`, font 11.
Regular: `padding(.horizontal, 15).padding(.vertical, 8)`, font 13. `fontWeight(.semibold)`.
`clipShape(.rect(cornerRadius: Theme.chipCornerRadius))`.

### StepperView

Two variants: `Int` (step 1, default) and `Double` (step 2.5 for weight).

```swift
struct StepperView: View {
    @Binding var value: Int
    var step: Int = 1
    var minimum: Int = 0
    var format: (Int) -> String = { "\($0)" }
}
```

Minus button: `28×28`, surface2 bg, border2 border, `clipShape(.rect(cornerRadius: 3))`.
Plus button: `28×28`, accent bg, accentDark color, `clipShape(.rect(cornerRadius: 3))`.
Value: `Theme.fontMono(20, .medium)`, `frame(minWidth: 36)`, centered.

### SetTrackerView

```swift
struct SetTrackerView: View {
    let totalSets: Int
    let completedSets: Int   // how many are done (exclusive upper bound)
    let currentSet: Int      // 0-indexed active set
}
```

`HStack(spacing: 7)` of `13×13` squares, `clipShape(.rect(cornerRadius: 2))`.
- `index < completedSets`: `background(Theme.accent)`, `.overlay(... stroke(Theme.accent, lineWidth: 1.5))`
- `index == currentSet`: `background(Theme.accentDim)`, `.overlay(... stroke(Theme.accent, lineWidth: 1.5))`
- else: `background(Theme.surface2)`, `.overlay(... stroke(Theme.border2, lineWidth: 1.5))`
- `.animation(.easeInOut(duration: 0.2), value: completedSets)`

### NavBarView

Generic: `struct NavBarView<Leading: View, Trailing: View>: View`.
`HStack`. `padding(.horizontal, Theme.horizontalPadding).padding(.vertical, 10)`. `frame(minHeight: 46)`.
Bottom divider via `.overlay(alignment: .bottom) { Rectangle().fill(Theme.border).frame(height: 1) }`.
Center: `Text(title ?? "").font(Theme.fontSans(15, .bold)).tracking(-0.2).foregroundStyle(Theme.text)`.

### ExerciseRow

```swift
struct ExerciseRow: View {
    let exercise: Exercise
    let isPickerMode: Bool
    let action: () -> Void
}
```

`Button(action: action)`. `padding(.horizontal, Theme.horizontalPadding).padding(.vertical, 13)`.
Leading VStack: name `fontSans(15, .bold)` + `MonoLabel("\(primaryMuscle) · \(equipment)", size: 9, tracking: 0.3)`.
If `exercise.isCustom`: amber `CUSTOM` badge — `MonoLabel("CUSTOM", size: 10, color: Theme.accent)` with `background(Theme.accentDim)`, `clipShape(.rect(cornerRadius: 2))`, `padding(.horizontal, 7).padding(.vertical, 2)`.
Trailing: `PlusIcon(size: 16, color: Theme.accent)` (picker) or `ChevronIcon(size: 14, color: Theme.text3)` (library).
Bottom divider: 1px `Theme.border`.

### ExercisePickerView

```swift
struct ExercisePickerView: View {
    let exercises: [Exercise]
    let onAdd: (Exercise) -> Void
    let onBack: () -> Void

    @State private var searchText = ""
    @State private var selectedFilter = "All"
}
```

`NavBarView` with back button, "Add Movement" title.
Search field: surface bg, border2, cornerRadius 4. `SearchIcon` at left, `padding(.leading, 32)`. `.onChange(of: searchText, ...)` — two-parameter form.
Filter row: `ScrollView(.horizontal, showsIndicators: false)` → `HStack(spacing: 6)` of small `ChipView`s. Filters: `["All","Chest","Back","Quads","Glutes","Core","Shoulders","Arms","Calves"]`.
List: `ScrollView → LazyVStack(spacing: 0)` of `ExerciseRow(isPickerMode: true)`.
Filter: `localizedStandardContains` for name, exact match for muscle.

**Verification:** SwiftUI `#Preview` for each component showing all states.

---

## Task 07 — App Entry Point & Navigation Shell

**Scope:** `BodyweightApp.swift`, `AppTabView.swift`, `BottomNav`. Screen content is placeholder `Text` — real screens wired in Tasks 08–17.

**Files:**
- `App/BodyweightApp.swift`
- `App/AppTabView.swift`

### BodyweightApp.swift

```swift
@main struct BodyweightApp: App {
    let container: ModelContainer
    let repositories: Repositories

    init() {
        do {
            container = try ModelContainer(for:
                Exercise.self, Workout.self, WorkoutItem.self, Session.self, SessionItem.self
            )
            let ctx = container.mainContext
            repositories = Repositories(
                exercises: SwiftDataExerciseRepository(context: ctx),
                workouts: SwiftDataWorkoutRepository(context: ctx),
                sessions: SwiftDataSessionRepository(context: ctx)
            )
        } catch { fatalError("ModelContainer failed: \(error)") }
    }

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .modelContainer(container)
                .environment(\.repositories, repositories)
                .task { await SeedManager.seedIfNeeded(context: container.mainContext) }
        }
    }
}
```

### AppTabView.swift

**Route enums** (in this file or in separate `AppRoutes.swift`):

```swift
enum AppTab: String, CaseIterable { case train, log, library }

enum TrainRoute: Hashable {
    case musclePicker
    case sessionBuilder(workoutID: PersistentIdentifier?, muscles: [String])
    case streak
}
enum LogRoute: Hashable { case sessionDetail(PersistentIdentifier) }
enum LibraryRoute: Hashable { case movementDetail(PersistentIdentifier); case customExercise }
```

(Using `PersistentIdentifier` instead of SwiftData models directly — `Hashable` conformance is guaranteed.)

**AppTabViewModel:**

```swift
@MainActor @Observable final class AppTabViewModel {
    var selectedTab: AppTab = .train
}
```

**AppTabView:**

```swift
struct AppTabView: View {
    @State private var tabVM = AppTabViewModel()
    @State private var trainPath: [TrainRoute] = []
    @State private var logPath: [LogRoute] = []
    @State private var libraryPath: [LibraryRoute] = []
    @State private var activeWorkoutID: PersistentIdentifier? = nil

    var isAtRoot: Bool { trainPath.isEmpty && logPath.isEmpty && libraryPath.isEmpty }

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
            if isAtRoot { BottomNav(tab: tabVM.selectedTab, setTab: { tabVM.selectedTab = $0 }) }
        }
        .background(Theme.bg)
        .fullScreenCover(item: $activeWorkoutID) { id in
            // ActiveWorkoutView — Task 11
        }
    }
}
```

Per-tab `NavigationStack(path: $trainPath)` with `navigationDestination(for: TrainRoute.self)`.

**BottomNav:**

```swift
struct BottomNav: View {
    let tab: AppTab
    let setTab: (AppTab) -> Void
}
```

`HStack`. Top border `Theme.border`. `background(Theme.bg)`.
3 buttons, `flex: 1`. Active: amber icon + `MonoLabel(label, size: 9, color: Theme.accent, tracking: 1.2)` + `16×2` amber indicator bar. Inactive: `rgba(245,240,232,0.28)` icon + text3 label + transparent bar.

**Verification:** Tabs switch. Nav depth tracked. BottomNav hides on push, re-appears on pop.

---

## Task 08 — Train Screen

**Scope:** `TrainViewModel` + `TrainView`. Wires into navigation for sub-screens (destinations are placeholder until Tasks 09–11).

**Files:**
- `ViewModels/TrainViewModel.swift`
- `Views/Train/TrainView.swift`

### TrainViewModel

```swift
@MainActor @Observable final class TrainViewModel {
    private let workouts: any WorkoutRepository
    private let sessions: any SessionRepository

    var savedWorkouts: [Workout] = []
    var isLoading = false
    var errorMessage: String? = nil

    init(workouts: any WorkoutRepository, sessions: any SessionRepository) { ... }

    func load() async { isLoading = true; defer { isLoading = false }; ... }

    func workoutsForToday() -> [Workout] {
        let dayAbbr = Date.now.formatted(.dateTime.weekday(.abbreviated)).uppercased()
        return savedWorkouts.filter { $0.scheduledDays.contains(dayAbbr) }
    }

    func delete(_ workout: Workout) async { ... }
}
```

### TrainView

Injected via `@Environment(\.repositories)`. Instantiates `TrainViewModel` in a `@State` property.

**Header** (`padding(.horizontal, 18).padding(.top, 16).padding(.bottom, 10)`):
- Left: `MonoLabel(currentDateString, size: 9, tracking: 1.2)` — format `"FRI, MAY 1"` — above `Text("OnlyBody").font(Theme.fontSans(26, .heavy)).tracking(-1).foregroundStyle(Theme.text)`
- Right: `34×34` amber `Button(action: { trainPath.append(.musclePicker) })` containing `PlusIcon(size: 15, color: Theme.accentDark)`

**Day strip** (`padding(.horizontal, 18).padding(.bottom, 10)`):
- `HStack(spacing: 4)` — `ForEach(["Sun","Mon","Tue","Wed","Thu","Fri","Sat"])`
- Each column: `VStack(alignment: .center, spacing: 5)` — `MonoLabel(day, size: 8, tracking: 0.3)` + `3×3` dot
- Today: `2px solid Theme.accent` bottom line; dot is amber if today, `Theme.border2` if scheduled, transparent otherwise

**Today callout** (`padding(.horizontal, 18).padding(.bottom, 10)`):
- Today's workouts non-empty: `background(Theme.accentDim)`, `padding(10×14)`, `overlay(alignment: .leading) { Rectangle().fill(Theme.accent).frame(width: 2) }` — `MonoLabel("Today")` + workout names
- Rest day: same shape but dim border, `MonoLabel("Rest day")`

**Workout list** (`ScrollView → LazyVStack(spacing: 0)`):
- `ForEach(savedWorkouts, id: \.id)` — each row:
  - Left 2px border: accent if today's workout, transparent otherwise
  - `HStack`: `VStack(alignment: .leading, spacing: 3)` (name + MonoLabel days/mvmts) + edit icon button + START→ button
  - Edit: `Button(action: { trainPath.append(.sessionBuilder(workoutID: w.id, muscles: [])) })`
  - START→: `padding(.horizontal, 14).frame(height: 36)`, amber bg, accentDark, `fontMono(11, .medium).tracking(1.2)` — sets `activeWorkoutID = w.id`

`.task { await viewModel.load() }`. Error alert on `viewModel.errorMessage`.

**Verification:** Workouts list renders. Today highlighted. Day strip dots match workout schedules.

---

## Task 09 — Muscle Picker Screen

**Scope:** `MusclePickerViewModel` + `MusclePickerView`. Pushed to trainPath when user taps `+`.

**Files:**
- `ViewModels/MusclePickerViewModel.swift`
- `Views/Train/MusclePickerView.swift`

### MusclePickerViewModel

```swift
@MainActor @Observable final class MusclePickerViewModel {
    let muscleGroups = ["Chest","Back","Shoulders","Arms","Core","Quads",
                        "Glutes","Hamstrings","Calves","Full Body","Upper","Lower"]
    var selectedMuscleGroups: [String] = []

    func toggle(_ muscle: String) { ... }

    var selectionSummary: String { selectedMuscleGroups.joined(separator: " + ") }
    var canBuild: Bool { !selectedMuscleGroups.isEmpty }
}
```

### MusclePickerView

Receives `trainPath` binding as parameter (or uses `@Environment` pattern for path).

- `NavBarView`: `BackIcon` button (pops trainPath) + "New Session" center
- `ScrollView → VStack(alignment: .leading, spacing: ...)`:
  - `Text("What are you training?").font(Theme.fontSans(24, .heavy)).tracking(-0.8)`
  - `MonoLabel("Select muscle groups", size: 10, tracking: 1)`
  - Flow layout of 12 `ChipView`s — use `LazyVGrid` with adaptive columns or a `FlowLayout` helper
  - If `canBuild`: `Text(selectionSummary).font(Theme.fontMono(11)).foregroundStyle(Theme.accent).tracking(0.5)`
- Bottom sticky: `VStack(spacing: 10)`:
  - `PrimaryButton("Build session →", isDisabled: !viewModel.canBuild)` → push `.sessionBuilder(workoutID: nil, muscles: viewModel.selectedMuscleGroups)`
  - `Button("Skip — pick movements myself")` in `font(Theme.fontSans(13)).foregroundStyle(Theme.text3)` → push `.sessionBuilder(workoutID: nil, muscles: [])`

**Verification:** Chips toggle. Summary text updates. Button disabled until selection.

---

## Task 10 — Session Builder Screen

**Scope:** `SessionBuilderViewModel` + `SessionBuilderView`. Handles create (from MusclePickerView) and edit (from workout row) modes. Embeds `ExercisePickerView` for adding movements.

**Files:**
- `ViewModels/SessionBuilderViewModel.swift`
- `Views/Train/SessionBuilderView.swift`

### SessionBuilderViewModel

```swift
@MainActor @Observable final class SessionBuilderViewModel {
    private let workoutRepo: any WorkoutRepository
    private let exerciseRepo: any ExerciseRepository

    var existingWorkout: Workout? = nil
    var initialMuscles: [String] = []
    var name: String = ""
    var mode: String = "smart"
    var movements: [MovementEntry] = []
    var scheduledDays: [String] = []
    var isSaving = false
    var errorMessage: String? = nil

    struct MovementEntry: Identifiable {
        var id = UUID()
        var exercise: Exercise
        var sets: Int = 3
        var reps: Int = 12
        var restSeconds: Int = 45
    }

    var estimatedDurationMinutes: Int {
        let total = movements.reduce(0) { $0 + $1.sets * 30 + max(0, $1.sets - 1) * $1.restSeconds }
        return Int((Double(total) / 60).rounded())
    }

    init(workoutRepo: any WorkoutRepository, exerciseRepo: any ExerciseRepository,
         existingWorkout: Workout? = nil, initialMuscles: [String] = []) {
        // Pre-populate from existingWorkout if editing
    }

    func addMovement(_ exercise: Exercise) { movements.append(MovementEntry(exercise: exercise)) }
    func removeMovement(at index: Int) { movements.remove(at: index) }

    func save() async throws {
        // Create or update Workout + WorkoutItems via workoutRepo.save(_:)
    }
}
```

### SessionBuilderView

- `NavBarView`: BackButton, "New Session"/"Edit Session" center, amber `Button("Save")` → `save()` + pop
- **TARGETS** (if initialMuscles non-empty): amber dim read-only chip tags
- **SESSION NAME**: `TextField` with surface bg, border2
- **SET STYLE**: 2-wide `HStack` of `ChipView`s — "Smart pick" / "I choose"
- **Smart mode info card**: surface bg, border, name + description text
- **Manual mode movements list**:
  - Header row: `MonoLabel("Movements")` + amber `Button("Add")` with `PlusIcon` → `showingExercisePicker = true`
  - Empty state: dashed border, `MonoLabel("No movements yet")`
  - `ForEach(movements.enumerated())` cards: drag icon, name, meta MonoLabel, `RemoveIcon` button (danger), inline steppers
  - Inline steppers: Sets (step 1), Reps (step 1), Rest (step 15, format `"\($0)s"`)
- **TRAINING DAYS**: small `ChipView`s for `["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]`
- **Est. duration** (if movements non-empty): `"~N min"` in amber Mono
- `ExercisePickerView` as `.sheet(isPresented: $showingExercisePicker)` with `onAdd: viewModel.addMovement`

**Verification:** Create and edit modes. Duration updates in real time. Movements persist.

---

## Task 11 — Active Workout Screen

**Scope:** `ActiveWorkoutViewModel` + `ActiveWorkoutView` — includes rest overlay and session-complete state. Session saved to SwiftData on completion.

**Files:**
- `ViewModels/ActiveWorkoutViewModel.swift`
- `Views/Train/ActiveWorkoutView.swift`

### ActiveWorkoutViewModel

```swift
@MainActor @Observable final class ActiveWorkoutViewModel {
    private let sessionRepo: any SessionRepository
    let restTimer: RestTimer

    let workout: Workout
    var exercises: [WorkoutItem] = []
    var currentExerciseIndex: Int = 0
    var currentSetIndex: Int = 0
    var completedSetsData: [String: Int] = [:]  // "eIdx-sIdx" → reps
    var repsValues: [String: Int] = [:]          // "eIdx-sIdx" → displayed reps
    var weightValues: [Int: Double] = [:]        // eIdx → kg
    var elapsedSeconds: Int = 0
    var isComplete: Bool = false
    var errorMessage: String? = nil

    private var elapsedTask: Task<Void, Never>? = nil

    func start() { /* load exercises from workout.items sorted by order, start elapsed */ }

    var currentExercise: WorkoutItem? { exercises[safe: currentExerciseIndex] }
    var progress: Double { exercises.isEmpty ? 0 : Double(currentExerciseIndex) / Double(exercises.count) }
    var formattedElapsed: String { /* "MM:SS" */ }
    func currentReps() -> Int { repsValues[key(currentExerciseIndex, currentSetIndex)] ?? (currentExercise?.targetReps ?? 0) }

    func markSetDone() {
        // Record reps, advance set or exercise, start rest timer, or trigger completion
        // On completion: stopElapsedTimer(), saveSession()
    }

    func previousExercise() { ... }
    func skipExercise() { ... }

    func endSession() async { await saveSession() }

    private func saveSession() async {
        // Create Session + SessionItems from completedSetsData
        // caloriesBurned ≈ elapsedSeconds / 60 * 8 (rough estimate)
    }
}
```

### ActiveWorkoutView

Presented via `fullScreenCover` from `AppTabView`.

**ZStack layers (bottom to top):**

1. **Main content** (`VStack`, fill):
   - Top bar (`HStack`): `MonoLabel("\(idx+1)/\(total)", size: 11, tracking: 0.5)` + `Text(formattedElapsed).font(Theme.fontMono(15)).foregroundStyle(Theme.text2)` + `GhostButton("End")`
   - Progress bar: `GeometryReader`-free — `Rectangle().fill(Theme.accent).frame(height: 2).frame(maxWidth: .infinity, alignment: .leading)` with `scaleEffect(x: progress, anchor: .leading)`, `.animation(.easeInOut(duration: 0.4), value: progress)`
   - Scrollable body: exercise name 38/800, MonoLabel set/target caption, `SetTrackerView`, reps card, weight card, prev/skip buttons, "UP NEXT" spacer section
   - Bottom fixed: `PrimaryButton("Mark Set Done")`

2. **Recovery overlay** (`.zIndex(20)`, shown when `restTimer.isActive`):
   - Centered `VStack`: `MonoLabel("Recovery", tracking: 3)` + `Text(formattedRestTime).font(Theme.fontMono(84, .medium)).foregroundStyle(Theme.accent).tracking(-4)` + next exercise label + `GhostButton("Skip rest")`
   - Full screen `background(Theme.bg)`

3. **Session complete overlay** (`.zIndex(30)`, shown when `isComplete`):
   - Centered `VStack`: `MonoLabel("Session complete")` + `Text(formattedElapsed).font(Theme.fontMono(72, .medium)).foregroundStyle(Theme.accent).tracking(-3)` + `MonoLabel("\(total) movements done")` + `PrimaryButton("Close").frame(maxWidth: 200)` → dismiss fullScreenCover

Reps card and weight card: `background(Theme.surface).clipShape(.rect(cornerRadius: Theme.cornerRadius)).overlay(border)`, `padding(12/14)`, `MonoLabel` caption + `StepperView`.

`.task { viewModel.start() }` on appear.

**Verification:** Full workout run end-to-end. Rest overlay auto-dismisses when timer hits 0. Session appears in Log after completion.

---

## Task 12 — Log Screen

**Scope:** `LogViewModel` + `LogView`. Tab-root read-only session history, grouped by month.

**Files:**
- `ViewModels/LogViewModel.swift`
- `Views/Log/LogView.swift`

### LogViewModel

```swift
@MainActor @Observable final class LogViewModel {
    private let sessions: any SessionRepository

    var allSessions: [Session] = []
    var isLoading = false
    var errorMessage: String? = nil

    var groupedByMonth: [(key: String, value: [Session])] {
        // Group most-recent-first sessions by "MONTH YYYY" label
        // Preserves insertion order (most recent month first)
    }

    func load() async { ... }
}
```

Month key: `session.date.formatted(.dateTime.month(.wide).year()).uppercased()` — e.g., `"MAY 2026"`. Display as `"MAY"` (strip year if same year as today).

### LogView

- **Header** (padding, not NavBar):
  - `MonoLabel("Training history", size: 9, tracking: 1.2)`
  - `Text("Log").font(Theme.fontSans(26, .heavy)).tracking(-1)`
- `ScrollView → LazyVStack(spacing: 0)`:
  - `ForEach(groupedByMonth)`:
    - `MonoLabel(month, size: 10, tracking: 1).padding(.bottom, 10).padding(.top, 22)`
    - `ForEach(sessions)`: `Button` → push `.sessionDetail(session.id)` to logPath
      - `HStack(spacing: 14)`: date square + VStack(name 14/700 + MonoLabel "DAY · DURATION · CALS kcal") + `ChevronIcon`
      - Date square: `38×38`, surface bg, border2 border, `clipShape(.rect(cornerRadius: 4))`, `Text(dayNum).font(Theme.fontMono(16, .medium))`
      - Bottom divider
- `.task { await viewModel.load() }`
- Empty state: centered `MonoLabel("No sessions yet")`

Duration formatting for display: `session.durationSeconds` → `"MM:SS"`.

**Verification:** Sessions grouped. Month headers render. Navigation to detail works.

---

## Task 13 — Session Detail Screen

**Scope:** `SessionDetailViewModel` + `SessionDetailView`. Drill-down from log row.

**Files:**
- `ViewModels/SessionDetailViewModel.swift`
- `Views/Log/SessionDetailView.swift`

### SessionDetailViewModel

```swift
@MainActor @Observable final class SessionDetailViewModel {
    let session: Session

    var formattedDate: String {
        session.date.formatted(.dateTime.weekday(.wide).month(.wide).day()).uppercased()
        // → "FRIDAY, MAY 1"
    }

    var formattedDuration: String {
        let m = session.durationSeconds / 60
        let s = session.durationSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    func totalReps(for item: SessionItem) -> Int { item.setReps.reduce(0, +) }

    var sortedItems: [SessionItem] { (session.items ?? []).sorted { $0.order < $1.order } }
}
```

No async needed — data passed via init.

### SessionDetailView

- `NavBarView`: BackButton, `session.workoutName` center
- `MonoLabel(formattedDate, size: 9, tracking: 0.5).padding(.bottom, 6)`
- `HStack(spacing: 20).padding(.bottom, 24)`:
  - Duration: `Text(formattedDuration).font(Theme.fontMono(24, .medium)).foregroundStyle(Theme.accent)` + `Text("min").font(Theme.fontSans(12)).foregroundStyle(Theme.text2)`
  - Cals: `Text("\(cals)").font(Theme.fontMono(24, .medium))` + `Text("kcal")`
- `ForEach(sortedItems)`:
  - `HStack`: name 14/700 + `Spacer()` + `MonoLabel("\(totalReps) REPS TOTAL", size: 9, tracking: 0.3)`
  - `ForEach(item.setReps.enumerated(), id: \.offset)`: `MonoLabel("SET \(n+1) · \(reps) REPS", size: 9, tracking: 0.3)`
  - Bottom divider
- `GhostButton("Repeat this session").frame(maxWidth: .infinity).padding(.top, 20)`

**Verification:** All set breakdowns show. Duration and cals render correctly.

---

## Task 14 — Library Screen

**Scope:** `LibraryViewModel` + `LibraryView`. Exercise catalog with search and muscle filter.

**Files:**
- `ViewModels/LibraryViewModel.swift`
- `Views/Library/LibraryView.swift`

### LibraryViewModel

```swift
@MainActor @Observable final class LibraryViewModel {
    private let exercises: any ExerciseRepository

    var allExercises: [Exercise] = []
    var searchText: String = ""
    var selectedFilter: String = "All"
    var isLoading = false
    var errorMessage: String? = nil

    let filters = ["All","Chest","Back","Shoulders","Arms","Core","Quads","Glutes","Hamstrings","Calves"]

    var filteredExercises: [Exercise] {
        allExercises.filter {
            (selectedFilter == "All" || $0.primaryMuscle == selectedFilter) &&
            (searchText.isEmpty || $0.name.localizedStandardContains(searchText))
        }
    }

    func load() async { ... }
}
```

### LibraryView

- **Header** (`HStack`):
  - `VStack(alignment: .leading)`: `MonoLabel("Movement catalog", size: 9, tracking: 1.2)` + `Text("Library").font(Theme.fontSans(26, .heavy))`
  - `Button`: `32×32` amber, `PlusIcon(size: 14, color: Theme.accentDark)` → push `.customExercise` to libraryPath
- Search field + filter chips (with bottom border):
  - `TextField` with `SearchIcon` overlay, surface bg, border2, cornerRadius 4
  - `ScrollView(.horizontal, showsIndicators: false)` → small `ChipView`s
  - `.onChange(of: viewModel.searchText) { oldVal, newVal in ... }` — two-param form
- `ScrollView → LazyVStack(spacing: 0)`: `ExerciseRow(isPickerMode: false)` per filtered exercise → push `.movementDetail(exercise.id)` to libraryPath
- `.task { await viewModel.load() }`

**Verification:** Search, filter, CUSTOM badge, navigation to detail.

---

## Task 15 — Movement Detail Screen

**Scope:** `MovementDetailViewModel` + `MovementDetailView`. Frequency preference persisted immediately on tap.

**Files:**
- `ViewModels/MovementDetailViewModel.swift`
- `Views/Library/MovementDetailView.swift`

### MovementDetailViewModel

```swift
@MainActor @Observable final class MovementDetailViewModel {
    private let exercises: any ExerciseRepository
    var exercise: Exercise

    init(exercise: Exercise, exercises: any ExerciseRepository) { ... }

    func setFrequency(_ value: String) async {
        exercise.frequencyPreference = value
        try? await exercises.save(exercise)
    }
}
```

### MovementDetailView

- `NavBarView`: BackButton, "Movement" center
- `Text(exercise.name).font(Theme.fontSans(26, .heavy)).tracking(-0.8).padding(.bottom, 4)`
- If `exercise.isCustom`: `MonoLabel("CUSTOM", size: 10, color: Theme.accent)` with accentDim bg, `clipShape(.rect(cornerRadius: 2))`, `padding(3/9)`, `.padding(.bottom, 16)`
- Divider
- **PRIMARY MUSCLE**: `MonoLabel("Primary muscle")` + `HStack(spacing: 8)`: `Rectangle().fill(Theme.accent).frame(width: 8, height: 8).clipShape(.rect(cornerRadius: 1))` + `Text(primaryMuscle).font(Theme.fontSans(14, .semibold))`
- **SECONDARY**: same shape, `Theme.border2` square, `text2` color. Secondary muscles joined by `", "`. Muscle diagram placeholder below: `120pt` height, surface bg, border, cornerRadius 4, centered `MonoLabel("[ muscle diagram ]")`
- Divider
- **Equipment**: `HStack` — `Text("Equipment").font(Theme.fontSans(13)).foregroundStyle(Theme.text2)` + `Spacer()` + `Text(equipment).font(Theme.fontMono(13, .bold))`
- Divider
- **INCLUDE IN SESSIONS**: `MonoLabel("Include in sessions")` + `HStack(spacing: 8)` of 3 equal-flex `ChipView`s: "More often" (`"more"`), "Less often" (`"less"`), "Exclude" (`"never"`) — `.task(id: tappedFreq) { await viewModel.setFrequency(tappedFreq) }`

**Verification:** Frequency change persists after navigate-away and return.

---

## Task 16 — Custom Exercise Form

**Scope:** `CustomExerciseViewModel` + `CustomExerciseForm`. Sheet from Library screen.

**Files:**
- `ViewModels/CustomExerciseViewModel.swift`
- `Views/Library/CustomExerciseForm.swift`

### CustomExerciseViewModel

```swift
@MainActor @Observable final class CustomExerciseViewModel {
    private let exercises: any ExerciseRepository

    var name: String = ""
    var primaryMuscle: String = ""
    var secondaryMuscles: [String] = []
    var selectedEquipment: [String] = []
    var isSaving = false
    var errorMessage: String? = nil

    let muscleOptions = ["Chest","Back","Shoulders","Arms","Core","Quads",
                         "Glutes","Hamstrings","Calves","Full Body"]
    let equipmentOptions = ["None","Dumbbells","Pull-up Bar","Resistance Bands","Kettlebell","Barbell"]

    var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && !primaryMuscle.isEmpty }

    func save() async throws {
        let ex = Exercise()
        ex.name = name.trimmingCharacters(in: .whitespaces)
        ex.primaryMuscle = primaryMuscle
        ex.secondaryMuscles = secondaryMuscles
        ex.equipment = selectedEquipment.isEmpty ? ["None"] : selectedEquipment
        ex.isCustom = true
        try await exercises.save(ex)
    }
}
```

### CustomExerciseForm

Presented as `.sheet` from `LibraryView`.

- `NavBarView`: `GhostButton("Cancel")` leading (dismiss sheet), "New Exercise" center, amber `Button("Save", isDisabled: !viewModel.isValid)` → `save()` then dismiss
- Scrollable body:
  - **Name**: `MonoLabel` + `TextField`, surface bg, border2
  - **Primary muscle**: `MonoLabel` + flow of single-select `ChipView`s (toggling activates, tapping active one deactivates — or stays selected once picked)
  - **Secondary muscles** (optional): `MonoLabel` + multi-select `ChipView`s
  - **Equipment**: `MonoLabel` + multi-select `ChipView`s

**Verification:** Exercise saved with `isCustom: true`. CUSTOM badge appears in Library.

---

## Task 17 — Streak Screen

**Scope:** `StreakViewModel` + `StreakView`. Pushed from Train screen header.

**Files:**
- `ViewModels/StreakViewModel.swift`
- `Views/Train/StreakView.swift`

Navigation: add a `Button` wrapping the "OnlyBody" title in `TrainView` that pushes `.streak` to trainPath.

### StreakViewModel

```swift
@MainActor @Observable final class StreakViewModel {
    private let sessions: any SessionRepository
    private let calculator = StreakCalculator()

    var stats: StreakCalculator.Stats? = nil
    var heatmap: [[Bool]] = []  // [weekIndex 0..19][dayIndex 0..6 Sun–Sat]
    var isLoading = false

    func load() async {
        isLoading = true; defer { isLoading = false }
        let all = (try? await sessions.allSessions()) ?? []
        stats = calculator.calculate(sessions: all)
        heatmap = buildHeatmap(from: all)
    }

    private func buildHeatmap(from sessions: [Session]) -> [[Bool]] {
        // Last 20 weeks × 7 days
        // session day set: Set<Date> (startOfDay)
        // For week w (0=most recent), day d: date = today - w*7 - (6-d) days
        // cell = sessionDays.contains(date)
    }
}
```

### StreakView

- `NavBarView`: BackButton, "Streak" center
- **Stat cards** — `HStack(spacing: 10)`, each `flex: 1`, surface bg, border, cornerRadius 4, `padding(14/10)`, centered:
  - Current: `Text("\(stats?.current ?? 0)").font(Theme.fontMono(26, .medium)).foregroundStyle(Theme.text3)`
  - Longest: same, `Theme.accent`
  - Total: same, `Theme.accent`
  - Below each value: `MonoLabel("CURRENT"/"LONGEST"/"TOTAL", size: 9, tracking: 0.5)`
- `MonoLabel("Activity — last 20 weeks", size: 10).padding(.bottom, 12)`
- **Heatmap card** (surface bg, border, cornerRadius 4, padding 14):
  - `VStack(spacing: 3)` of 7 rows (Sun–Sat)
  - Each row: `HStack(spacing: 3)` of 20 cells
  - Cell: `.frame(maxWidth: .infinity).frame(height: 9).clipShape(.rect(cornerRadius: 1)).background(filled ? Theme.accent : Theme.surface2)`
- `MonoLabel("Manage streak in Settings", size: 9, tracking: 0.5).frame(maxWidth: .infinity, alignment: .center).padding(.top, 14)`
- `.task { await viewModel.load() }`

**Verification:** Heatmap reflects actual session history. Stats match `StreakCalculator` output.

---

## Task 18 — Unit & Integration Tests

**Scope:** Complete test suite. All tests must pass with `swift test`.

**Files:**
- `Tests/ServicesTests/StreakCalculatorTests.swift`
- `Tests/ServicesTests/SmartWorkoutGeneratorTests.swift`
- `Tests/ServicesTests/RestTimerTests.swift`
- `Tests/ViewModelsTests/TrainViewModelTests.swift`
- `Tests/ViewModelsTests/SessionBuilderViewModelTests.swift`
- `Tests/ViewModelsTests/ActiveWorkoutViewModelTests.swift`
- `Tests/Mocks/MockExerciseRepository.swift`
- `Tests/Mocks/MockWorkoutRepository.swift`
- `Tests/Mocks/MockSessionRepository.swift`

### Mock Repositories

```swift
@MainActor final class MockWorkoutRepository: WorkoutRepository {
    var stubbedWorkouts: [Workout] = []
    var savedWorkouts: [Workout] = []
    var shouldThrow = false

    func allWorkouts() async throws -> [Workout] { if shouldThrow { throw TestError.mock }; return stubbedWorkouts }
    func save(_ workout: Workout) async throws { if shouldThrow { throw TestError.mock }; savedWorkouts.append(workout) }
    func delete(_ workout: Workout) async throws { }
}
// Similar pattern for MockExerciseRepository, MockSessionRepository
```

### StreakCalculatorTests

| Test | Input | Expected |
|---|---|---|
| `testEmpty` | `[]` | `(0, 0, 0)` |
| `testSingleSessionToday` | 1 session = today | `(1, 1, 1)` |
| `testSingleSessionYesterday` | 1 session = yesterday | `(0, 1, 1)` |
| `testConsecutive3Days` | today, yesterday, day-2 | `(3, 3, 3)` |
| `testGapBreaksCurrent` | today, yesterday, day-3, day-4 | `current=2, longest=2, total=4` |
| `testLongestIsPastRun` | 5 consecutive last month + 1 today | `current=1, longest=5, total=6` |
| `testDuplicateDayNotDoubleCounted` | 2 sessions same day | `current=1, longest=1, total=2` |

### SmartWorkoutGeneratorTests

- `testExcludesNeverExercises()` — pool with 1 "never" + 2 "normal" → result contains only normal
- `testMoreExercisesPickedFirst()` — "more" exercise always appears before "normal" in result
- `testTimeBudgetRespected()` — budget 10 min, large pool → total estimated duration ≤ 600s
- `testFallbackWhenOnlyOneMatch()` — 1 matching exercise (non-None equipment) → fallback returns equipment-free result
- `testMuscleGroupFilter()` — Chest-only pool, request `["Back"]` → fallback triggered

### RestTimerTests

- `testStartSetsIsActive()` — after `start(seconds: 5, ...)`, `isActive == true`, `remainingSeconds == 5`
- `testSkipResetsState()` — after `start` then `skip`, `isActive == false`, `remainingSeconds == 0`
- `testCountsDown()` — start, sleep 2.1s, remaining ≤ 3 (allowing for timing tolerance)

### TrainViewModelTests

- `testLoadPopulatesSavedWorkouts()` — mock returns 3 workouts → `savedWorkouts.count == 3`
- `testLoadSetsErrorOnFailure()` — mock throws → `errorMessage != nil`
- `testIsLoadingToggledDuringLoad()` — verify true during, false after
- `testWorkoutsForToday()` — workout with `["Mon"]`, mock date = Monday → returned in today's list

### SessionBuilderViewModelTests

- `testAddMovement()` — `addMovement(exercise)` → `movements.count == 1`
- `testRemoveMovement()` — add 2, remove at 0 → remaining is second
- `testEstimatedDuration()` — 1 movement: sets=3, reps=12, rest=45 → `3*30 + 2*45 = 180s = 3 min`
- `testSaveCallsRepository()` — `save()` → `mockWorkoutRepo.savedWorkouts.count == 1`
- `testEditModePrePopulates()` — init with existing workout → `name == workout.name`, movements populated

### ActiveWorkoutViewModelTests

- `testMarkSetDoneAdvancesSet()` — 3 sets, markDone on set 0 → `currentSetIndex == 1`
- `testMarkSetDoneOnLastSetAdvancesExercise()` — last set of exercise 0 → `currentExerciseIndex == 1`
- `testCompletionTriggered()` — last set of last exercise → `isComplete == true`
- `testCompletedSetsTracked()` — markDone with reps=10 → `completedSetsData["0-0"] == 10`
- `testSessionSavedOnCompletion()` — complete workout → `mockSessionRepo.savedSessions.count == 1`

### Repository Integration Tests (in-memory)

- `testExerciseSaveAndFetch()` — insert exercise, fetch all → returned
- `testWorkoutSaveAndDelete()` — insert, delete, fetch → empty
- `testSessionRecentLimit()` — insert 5 sessions, `recentSessions(limit: 3)` → 3 most recent

**Verification:** `swift test` passes all cases. Zero force-unwraps in test code.

---

## Implementation Notes

- Tasks 02–06 have no UI — they can be reviewed via unit tests and `#Preview` only.
- Tasks 07–17 each introduce one screen or navigation layer.
- Task 18 should be written alongside each implementation task (test-alongside approach) — the test file list in Task 18 is the minimum; individual task agents may add tests as they go.
- No UI tests for MVP.
- No third-party dependencies — all SwiftUI, SwiftData, Foundation, Observation.
- All views are dark-only: `UIUserInterfaceStyle = Dark` in Info.plist prevents any light-mode rendering.
- `DM Sans` and `DM Mono` must be added to the project target and listed in `Info.plist` under `UIAppFonts`.
