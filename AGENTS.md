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
- **Repositories** — protocols (`ExerciseRepository`, `WorkoutRepository`, `SessionRepository`, `SmartDailyVariantRepository`) with `SwiftData*` implementations. Contracts expose only detached snapshots. Save entire workout aggregates atomically; do not introduce a separate `deleteItems` write. Swap implementations without touching views or view models.
- **Services** — contain logic that doesn't belong in a ViewModel. Prefer pure structs when there is no mutable state across time (`SmartWorkoutGenerator`, `StreakCalculator`). Use `@MainActor @Observable final class` only when the service owns persistent mutable state (`RestTimer` manages countdown state across view renders). No SwiftData imports in services.
- **Repository injection** — repositories are concrete-typed once at app entry in `BodyweightApp.init()`, then injected into `AppComposition` as protocol types. App-level navigation roots use that factory; feature screens receive ViewModels. ViewModels never see concrete SwiftData types.
- **No ViewModel-to-ViewModel dependencies.** Pass data through navigation, not shared state.
- **Theme.swift** is the only cross-cutting dependency for views — everything else is injected.

### Preview Repositories

`Shared/Preview/` contains `#if DEBUG`-gated structs (`PreviewWorkoutRepository`, `PreviewExerciseRepository`, `PreviewSessionRepository`, `PreviewSmartDailyVariantRepository`) that implement each repository protocol with fixed fixture data. Reads return injected arrays; writes are no-ops. Use these in `#Preview` blocks — never create a live `ModelContainer` in previews. The DEBUG app initializer detects `XCODE_RUNNING_FOR_PREVIEWS` and injects preview repositories without opening or copying a store. Inject fixtures into preview repositories so view `.task` loads preserve the data.

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

The repository root is `onlybody`; `Apps/`, `Website/`, `Scripts/` and `Assets/` are sibling directories; the Xcode project is `Apps/iOS/Apps.xcodeproj`. The source root is `Apps/iOS/Sources/`; source and test groups are filesystem-synchronized.
New files need no project edits. New targets do require project configuration.

- `App/`: composition root, `AppComposition`, system tab shell and per-tab navigation roots.
- `Domain/Models/`: detached `Sendable` value snapshots; never import SwiftData or SwiftUI.
- `Domain/Repositories/`: `@MainActor` async protocols accepting/returning snapshots.
- `Domain/Services/`: pure business logic and observable timers with injected time.
- `Domain/Catalog/`: shared domain enums and catalog constants.
- `Core/Persistence/Models/`: unchanged SwiftData entities. Preserve their names and schema for store compatibility.
- `Core/Persistence/Mapping/`: explicit persistence-to-domain mapping.
- `Core/Persistence/Repositories/`: SwiftData writes in private contexts, autosave off, one save with rollback per aggregate.
- `Features/{Train,Log,Library,Settings}/`: screens, ViewModels and feature-local components.
- `Core/{Notifications,LiveActivity,Audio,Preferences,Connectivity}/`: system adapters wired at the composition boundary.
- `Apps/iOS/WorkoutActivity/`: shared Live Activity extension UI for both products.
- `Shared/{Theme,Icons,Components,Preview}/`: visual primitives, tokens and no-op preview repositories.
- `Apps/iOS/Products/{OnlyBody,OnlyWeights}/`: target-specific generated catalogs, equipment lists, seed SQLite and brand assets. Shared source stays in `Apps/iOS/Sources/`; do not duplicate features.
- `Apps/iOS/Configuration/`: shared App.xcconfig and product identity settings.
- `Apps/iOS/ProductTests/{OnlyBody,OnlyWeights}/`: product-specific Swift Testing suites.
- Shared source and shared tests are filesystem-synchronized members of both corresponding targets. AppConfiguration selects product defaults at the composition boundary; views receive data via ViewModels.
- `Apps/iOS/Tests/`: Swift Testing unit and integration suites and mocks.
- `Apps/iOS/UITests/`: XCTest UI automation only, using real persistence in an isolated test store.
- `Scripts/validate.sh quick` (the default): lint, validator/workflow regression tests, boundary/catalog/localization checks and unit/integration tests for both products.
- `Scripts/validate.sh full`: additionally runs functional UI tests, Release builds, bundle checks and temporary seed generation; select explicitly.
- Both modes reuse the gitignored `DerivedData/Validation` build cache (override with `VALIDATION_DERIVED_DATA`, an absolute path). Logs and result bundles remain separate per run in `VALIDATION_OUTPUT` or a new temporary directory.
- `Apps/iOS/Configuration/TestPlans/`: each scheme defaults to Functional; Visual capture suites run only when explicitly requested. No validation mode selects Visual.


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
- `Theme.fontSans(_ size: CGFloat, _ weight: Font.Weight)` — system font, fixed size
- `Theme.fontMono(_ size: CGFloat, _ weight: Font.Weight)` — system font with monospaced digits, fixed size
- `Theme.horizontalPadding` — 20
- `Theme.cornerRadius` — 24
- `Theme.chipCornerRadius` — 12

---

## Navigation

System tab navigation uses SwiftUI `TabView(selection:)` with the `Tab` API and separate navigation stacks.

```swift
enum AppTab: Hashable { case train, log, library }

// AppTabView owns the selected tab and each tab's navigation path.
@State private var selectedTab: AppTab = .train
```

- `AppTabView` manages `selectedTab` and renders the system Liquid Glass tab bar. No custom horizontal swipe between tabs.
- Each tab owns its own `NavigationStack` with `navigationDestination(for:)`
- The system tab bar hides when a sub-screen is pushed using toolbar visibility (track navigation depth per tab). It does not minimize on scroll.
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
- **Font sizes:** OnlyBody uses a custom fixed typography scale in `Theme.swift`. Use `Theme.fontSans` and `Theme.fontMono` — NOT Dynamic Type text styles (`.title`, `.body`, etc.). System tab bar labels retain system typography.
- **Spacing/padding:** Always use `Theme` spacing constants. Do not call `.padding()` without a value — always reference `Theme.horizontalPadding` or an explicit `Theme` constant.
- Button with image must include text: `Button("Label", systemImage: "icon", action: ...)` — but prefer custom icon views over SF Symbols.
- **Icons:** Custom icons live in `Shared/Icons/` — one file per icon (e.g. `TrainIcon.swift`, `ChevronIcon.swift`). Each is a `Canvas`-based `View`. SF Symbols are permitted for the system tab bar; retain custom icons inside feature screens. Shared config lives in `AppIcons.swift` (`viewport: CGFloat = 24`, `stroke: StrokeStyle`). Canonical pattern:
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

- **App Store data safety:** If a proposed database change could cause data loss, corruption, or compatibility issues for existing users, explain the risks and the proposed migration and verification plan to the project owner, and get explicit approval before implementing the change.
- On-device only — `@Attribute(.unique)` is safe and should be used.
- All model properties must have default values OR be optional.
- Relationships must be optional when the related object may be deleted independently.
- Use `@Relationship(deleteRule: .cascade)` when a parent owns its children (e.g. `Workout.items`, `Session.items`). Use `@Relationship(deleteRule: .nullify)` for cross-references where the related object may be deleted independently (e.g. `WorkoutItem.workout` inverse).

- **Seed data**: Each exercise catalog is shipped as a pre-populated SQLite store in `Apps/iOS/Products/<Product>/Resources/SeedStore/default.store`, copied to Documents on first launch. No runtime JSON parsing or bulk inserts. When exercises change, regenerate with:
  ```bash
  swift run --package-path Scripts/StoreGenerator StoreGenerator \
    Apps/iOS/Products/OnlyBody/Resources/SeedStore/default.store \
    Scripts/StoreGenerator/SeedData.json
  ```

## Product changes

- Use shared schemes `onlybody` and `onlyweights`; Bundle IDs are `ikhvost.onlybody` and `ikhvost.onlyweights`.
- Common features, persistence entities and Theme remain shared. Never create permanent product Git branches or copy screens.
- OnlyBody authoring inputs remain `Scripts/StoreGenerator/SeedData.json` and `Scripts/ExerciseMedia/catalog.json`. OnlyWeights uses `Scripts/StoreGenerator/OnlyWeights/SeedData.json` and `Scripts/ExerciseMedia/onlyweights.json`.
- Metadata generators accept `--seed` and `--output`; media additionally accepts `--catalog` and `--allow-missing` for OnlyWeights. Keep full video coverage required for OnlyBody.
- Choose validation by the scope and risk of the change (see Testing below); a small UI change does not require `full`. Catalog, seed, persistence/schema, product identity/build configuration and broad architecture changes require `python3 Scripts/Validation/check-catalogs.py` and `Scripts/validate.sh full` for both products. Generate icons with `bash Scripts/AppIcon/generate.sh OnlyBody` or `OnlyWeights`.
- Do not regenerate OnlyBody's seed or rename existing exercises for a branding/build-structure change. Existing database path and model identities must remain stable.
- Build settings exclude SQLite WAL/SHM sidecars from both app bundles.
- Canonical exercise names are stable persisted keys, recorded in `Scripts/StoreGenerator/CatalogKeys.json`. The registry is append-only: add new keys explicitly; generators never rewrite it. Renaming/removing an existing key requires separate compatibility work. Change user-visible wording through translations.
- Each product provides `ExerciseLocalizationCatalog`; shared `CatalogLocalization` delegates exercise lookups to that table. Shared labels and `Localizable.xcstrings` remain common.
- Product compilation conditions in shared app sources are permitted only in `App/AppConfiguration.swift` and `Shared/Preview/NativeDesignReviewFixture.swift`. Tests may conditionally import the product module. Inject product policies at the composition boundary.

## Release preparation

- Use `Scripts/Release/prepare.sh <onlybody|onlyweights> <version> <build>` for release archives. Set `DESTINATION` to an installed iOS Simulator destination; for example `DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro' Scripts/Release/prepare.sh onlybody 1.2.0 42`.
- The script explicitly runs `Scripts/validate.sh full` for both products, then creates a signed Release device archive for the selected scheme and verifies its identity, version, provisioning profile and signature. Do not bypass validation or substitute a simulator Release build for a distribution archive.
- Use the exact Xcode version in `.xcode-version`. Release preparation does not accept `ALLOW_OLDER_XCODE`. Supply a three-component marketing version and a positive integer build number (1–9999); choose a new build number for each upload. Version overrides belong to the archive command, not edits to shared `App.xcconfig` just to prepare an archive.
- Signing requires the configured team's signing identity and provisioning profile. Set `ALLOW_PROVISIONING_UPDATES=1` only when Xcode should manage provisioning using its authenticated account. Never commit signing credentials.
- Keep archives and logs in the default gitignored `Release/` directory or a new `RELEASE_OUTPUT` directory. Preserve failure diagnostics; only a successful run writes `PREPARED`. Report actual validation/archive results and any blockers, never infer success from the existence of a partial archive.
- This script prepares an archive only; export, upload and App Review submission are separate actions. Complete the manual release checks below before distribution. A successful archive does not establish completed content review or App Store readiness.

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

Choose the smallest meaningful verification scope:

- Documentation-only changes: inspect the diff; no app builds or tests.
- Validation-script-only changes: check shell syntax and run `Scripts/Validation/test_validation_workflow.py` and the affected validator tests. Do not run app test suites unless an unresolved concern requires verification with real Xcode commands.
- Local visual changes (colors, spacing, typography, shapes), with no behavior, navigation, accessibility semantics or data changes: build the affected product(s), run SwiftLint and inspect the affected screen using a SwiftUI preview or focused simulator capture. Shared views must build for both products. Reuse `DerivedData/Validation` for these builds. Do not run `quick`, `full` or the entire screen matrix by default.
- ViewModel, service or repository logic: run `Scripts/validate.sh quick`; add only the relevant functional UI journeys when interaction or navigation changes. Shared behavior must be checked for both products.
- Catalog, seed, persistence/schema, product identity/build configuration or broad architecture changes: run `Scripts/validate.sh full`. Release preparation always requires `full` as described above. Also run it when explicitly requested.
- Choose one sufficient verification scope before starting. `full` includes every `quick` check: do not launch `quick` before, during or after a planned `full` run for the same source state. If a new change or failure requires broader checks, expand only as needed and explain the reason. Run builds and tests using the same cache sequentially; do not start overlapping validation or visual-test runs.
- Keep the build cache between runs; do not use a new DerivedData path or clean the cache for routine checks. Use a separate `VALIDATION_DERIVED_DATA` only for isolation or diagnosing a suspected cache issue. Keep result bundles separate and report the scope actually run.
- Report the checks actually completed. A deliberately interrupted full run is not a passing full run; do not repeat successful checks without a new change or unresolved concern.

Framework: **Swift Testing** (`@Test`, `#expect`) for unit and integration tests. **XCTest + XCUIAutomation is allowed only in `Apps/iOS/UITests/`**, compiled by `onlybodyUITests` / `onlyweightsUITests`. Functional coverage includes the journeys below, localization smoke and control hit areas.

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
- Unit-test all ViewModels using mock repository protocols. Mocks live in `Apps/iOS/Tests/Support/` (`MockWorkoutRepository`, `MockExerciseRepository`, `MockSessionRepository`). Each mock has a `shouldThrow` flag and records writes for assertion. Timer tests inject `ManualWorkoutTimeSource`; do not wait for wall-clock seconds.
- Integration-test repositories with in-memory `ModelContainer` (`ModelConfiguration(isStoredInMemoryOnly: true)`).
- Maintain the same five E2E journeys for both schemes: create/relaunch, edit, complete/history, early finish, navigation. Use Debug-only UUID-isolated file stores and real repositories, accessibility identifiers and bounded waits.
- Use SwiftUI previews and the opt-in native screen matrix for view iteration. Ordinary successful functional tests do not explicitly capture screenshots; retain failure screenshots and Xcode diagnostics.
- Use the Visual test plan only for requested store/release screenshots or the native design matrix; select the required suite with `-only-testing`. See README for commands. This does not replace mandatory media-review or release evidence.

## Code Quality

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
