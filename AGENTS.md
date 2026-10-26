# AGENTS.md — OnlyBody and OnlyWeights

## Project Overview

Two iOS apps sharing one source tree: OnlyBody for bodyweight training and OnlyWeights for gym training. Single user, on-device data in independent app sandboxes, no CloudKit. The app will evolve significantly — architecture must support frequent change with loose coupling and high cohesion.

---

## Target

- **iOS:** 26.0+
- **Swift:** 6.4 (Xcode 27.1), Swift 6 language mode, strict concurrency
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
- **Repositories** — protocols (`ExerciseRepository`, `WorkoutRepository`, `SessionRepository`) with `SwiftData*` implementations. Contracts expose only detached snapshots. Save entire workout aggregates atomically; do not introduce a separate `deleteItems` write. Swap implementations without touching views or view models.
- **Services** — contain logic that doesn't belong in a ViewModel. Prefer pure structs when there is no mutable state across time (`SmartWorkoutGenerator`, `StreakCalculator`). Use `@MainActor @Observable final class` only when the service owns persistent mutable state (`RestTimer` manages countdown state across view renders). No SwiftData imports in services.
- **Repository injection** — repositories are concrete-typed once at app entry in `BodyweightApp.init()`, then injected into `AppComposition` as protocol types. App-level navigation roots use that factory; feature screens receive ViewModels. ViewModels never see concrete SwiftData types.
- **No ViewModel-to-ViewModel dependencies.** Pass data through navigation, not shared state.
- **Theme.swift** is the only cross-cutting dependency for views — everything else is injected.

### Preview Repositories

`Shared/Preview/` contains `#if DEBUG`-gated structs (`PreviewWorkoutRepository`, `PreviewExerciseRepository`, `PreviewSessionRepository`) that implement each repository protocol with fixed fixture data. Reads return injected arrays; writes are no-ops. Use these in `#Preview` blocks — never create a live `ModelContainer` in previews. The DEBUG app initializer detects `XCODE_RUNNING_FOR_PREVIEWS` and injects preview repositories without opening or copying a store. Inject fixtures into preview repositories so view `.task` loads preserve the data.

```swift
#if DEBUG
struct PreviewWorkoutRepository: WorkoutRepository {
    let workouts: [WorkoutSnapshot]
    func allWorkouts() async throws -> [WorkoutSnapshot] { workouts }
    func workout(by id: UUID) async throws -> WorkoutSnapshot? { workouts.first { $0.id == id } }
    func save(_ workout: WorkoutSnapshot) async throws {}
}
#endif
```

### Project structure

The source root is `onlybody/onlybody/`; source and test groups are filesystem-synchronized.
New files need no project edits. New targets do require project configuration.

- `App/`: composition root, `AppComposition`, custom tab shell and per-tab navigation roots.
- `Domain/Models/`: detached `Sendable` value snapshots; never import SwiftData or SwiftUI.
- `Domain/Repositories/`: `@MainActor` async protocols accepting/returning snapshots.
- `Domain/Services/`: pure business logic and observable timers with injected time.
- `Domain/Catalog/`: shared domain enums and catalog constants.
- `Core/Persistence/Models/`: unchanged SwiftData entities. Preserve their names and schema for store compatibility.
- `Core/Persistence/Mapping/`: explicit persistence-to-domain mapping.
- `Core/Persistence/Repositories/`: SwiftData writes in private contexts, autosave off, one save with rollback per aggregate.
- `Features/{Train,Log,Library}/`: screens, ViewModels and feature-local components, one type per file.
- `Shared/{Theme,Icons,Components,Preview}/`: visual primitives, tokens and no-op preview repositories.
- `onlybody/Products/{OnlyBody,OnlyWeights}/`: target-specific generated catalogs, equipment lists, seed SQLite and brand assets. Shared source stays in `onlybody/onlybody/`; do not duplicate features.
- `onlybody/Configuration/`: shared App.xcconfig and product identity settings.
- `onlybody/ProductTests/{OnlyBody,OnlyWeights}/`: product-specific Swift Testing suites.
- Shared source and shared tests are filesystem-synchronized members of both corresponding targets. AppConfiguration selects product defaults at the composition boundary; views receive data via ViewModels.
- `onlybody/onlybodyTests/`: Swift Testing unit and integration suites and mocks.
- `onlybody/onlybodyUITests/`: XCTest UI automation only, using real persistence in an isolated test store.
- `Scripts/validate.sh`: lint, boundary checks, tests, Release build and temporary seed generation.


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
- `Theme.horizontalPadding` — 22
- `Theme.cornerRadius` — 4
- `Theme.chipCornerRadius` — 4

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

- **Seed data**: Each exercise catalog is shipped as a pre-populated SQLite store in `onlybody/Products/<Product>/Resources/SeedStore/default.store`, copied to Documents on first launch. No runtime JSON parsing or bulk inserts. When exercises change, regenerate with:
  ```bash
  swift run --package-path Scripts/StoreGenerator StoreGenerator \
    onlybody/Products/OnlyBody/Resources/SeedStore/default.store \
    Scripts/StoreGenerator/SeedData.json
  ```

## Product changes

- Use shared schemes `onlybody` and `onlyweights`; Bundle IDs are `ikhvost.onlybody` and `ikhvost.onlyweights`.
- Common features, persistence entities and Theme remain shared. Never create permanent product Git branches or copy screens.
- OnlyBody authoring inputs remain `Scripts/StoreGenerator/SeedData.json` and `Scripts/ExerciseMedia/catalog.json`. OnlyWeights uses `Scripts/StoreGenerator/OnlyWeights/SeedData.json` and `Scripts/ExerciseMedia/onlyweights.json`.
- Metadata generators accept `--seed` and `--output`; media additionally accepts `--catalog` and `--allow-missing` for OnlyWeights. Keep full video coverage required for OnlyBody.
- Run `python3 Scripts/Validation/check-catalogs.py` and the full `Scripts/validate.sh` for both products. Generate icons with `bash Scripts/AppIcon/generate.sh OnlyBody` or `OnlyWeights`.
- Do not regenerate OnlyBody's seed or rename existing exercises for a branding/build-structure change. Existing database path and model identities must remain stable.
- Build settings exclude SQLite WAL/SHM sidecars from both app bundles.

## Mandatory YouTube content and integration review

- **Always read and complete [Scripts/ExerciseMedia/CHECKLIST.md](Scripts/ExerciseMedia/CHECKLIST.md) before adding or replacing any video in either product.** Apply it also to video ID/author/start-offset changes, player changes and release review. This is a required repository workflow, not an optional suggestion.
- Record per-video URL, exact video title, author/channel, license type or explicit uncertainty, review date, reviewer, screenshots and all checklist results in `Scripts/ExerciseMedia/Reviews/<YYYY-MM-DD>/`. Link the evidence in the change description. Keep evidence outside app targets; never commit videos, cookies, tokens or private device identifiers.
- Review records and evidence in `Scripts/ExerciseMedia/Reviews/` are local, gitignored files at the user's request. Keep them on disk; do not force-add them to Git. Catalogs retain review status and a dated reference, but builds and generated-catalog checks must work without the local archive. References to dated reports in repository documentation point to this local archive.
- Verify the channel's provenance, review the complete video with sound for suspicious third-party material, inspect Share → Embed, and test real playback on a physical iPhone. Clearly distinguish browser samples, simulator/local-fixture tests and physical-device playback. Never invent a license, rights confirmation or a test result.
- Standard YouTube License is not automatically disqualifying for official embedding. Do not require Creative Commons, a purchased license or individual author permission solely because the video uses Standard licensing. Evaluate allowed embedding under current YouTube terms separately from permission to download, modify or redistribute files. Preserve evidence of any additional permissions actually obtained.
- Use only the official YouTube IFrame Player in WKWebView. Set app identification using `loadHTMLString(..., baseURL:)` with `https://<actual Bundle ID>`, matching origin and a non-suppressing referrer policy. The identities are `https://ikhvost.onlybody` and `https://ikhvost.onlyweights`; do not copy example Bundle IDs from documentation.
- Preserve a viewport of at least 200 × 200 CSS pixels, standard controls, YouTube branding, links and ads. Do not cover or crop the player or filter its advertising. Preserve the existing author caption; it is a project convention in addition to standard player attribution.
- Never extract streams, provide unauthorized offline copies, or charge for access to embedded YouTube playback. Normal buffering by the official player is not an app offline-download feature.
- Keep recoverable handling of errors 100, 101, 150 and 153, network loss, timeout, deletion and embedding restrictions. Exercise details and workouts must remain usable without a video.
- Before release, verify a user-accessible privacy policy and terms covering YouTube API Services, Google Privacy Policy, YouTube Terms, relevant data transfer/cookies/ads and applicable consent. A local draft or nonpersistent WebKit store is not proof of compliance. Keep an App Review evidence package; never promise approval.
- Mark outcomes PASS, FAIL, UNCONFIRMED or justified N/A. A generated catalog, a historical browser review or green tests do not establish legal clearance or complete checklist approval. Resolve failures before adding a video; explicitly document every remaining unknown and never label a partial review complete.
- Run shared `YouTubeIntegrationTests` for both app schemes after integration changes. OnlyBody additionally retains catalog and playback-state tests; OnlyWeights videos retain partial review status. See [media review status](Scripts/ExerciseMedia/README.md) for the dated local audits.

## Testing

Framework: **Swift Testing** (`@Test`, `#expect`) for unit and integration tests. **XCTest + XCUIAutomation is allowed only in `onlybodyUITests` / `onlyweightsUITests`**, as explicitly approved for the five E2E journeys.

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
- Unit-test all ViewModels using mock repository protocols. Mocks live in `onlybodyTests/Support/` (`MockWorkoutRepository`, `MockExerciseRepository`, `MockSessionRepository`). Each mock has a `shouldThrow` flag and records writes for assertion. Timer tests inject `ManualWorkoutTimeSource`; do not wait for wall-clock seconds.
- Integration-test repositories with in-memory `ModelContainer` (`ModelConfiguration(isStoredInMemoryOnly: true)`).
- Maintain the same five E2E journeys for both schemes: create/relaunch, edit, complete/history, early finish, navigation. Use Debug-only UUID-isolated file stores and real repositories, accessibility identifiers and bounded waits.
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
