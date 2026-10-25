# OnlyBody + OnlyWeights

Two on-device training apps built from the same SwiftUI and SwiftData source tree. No CloudKit or third-party application dependencies.

## Working on both apps

Open `onlybody/onlybody.xcodeproj` and choose the **onlybody** or **onlyweights** scheme. A shared feature edit is compiled into both apps; each is archived and released separately.

| Product | Bundle ID | Catalog | Branding |
| --- | --- | --- | --- |
| OnlyBody | `ikhvost.onlybody` | 65 bodyweight exercises, existing demonstrations | OB |
| OnlyWeights | `ikhvost.onlyweights` | 60 gym exercises; 60 videos in Debug and Release, content review incomplete | OW |

- Shared code, fonts, anatomy artwork and launch storyboard: `onlybody/onlybody/`.
- Product content and brand assets: `onlybody/Products/OnlyBody/` and `onlybody/Products/OnlyWeights/`. Each target includes only its own product folder.
- Build settings: `onlybody/Configuration/App.xcconfig`, with identity overrides in `OnlyBody.xcconfig` and `OnlyWeights.xcconfig`.
- `AppConfiguration` carries the display name and generator fallback policy through `AppComposition`. Features do not inspect build flags or bundles to discover their product.
- Both products use the same SwiftData schema and `Documents/default.store` path inside independent app sandboxes. OnlyBody keeps its existing Bundle ID, seed bytes and user-data location. There is no shared user database or cross-app sync.
- Shared test sources run in both test targets. Product-specific catalog tests live in `onlybody/ProductTests/`. `JourneyProduct` supplies real catalog names to the same five UI journeys.
- `bash Scripts/AppIcon/generate.sh OnlyWeights` renders OW icon and launch assets; passing `OnlyBody` renders OB. The existing OnlyBody assets are retained by this change.

## Toolchain

- Target: Xcode **27.1**, bundled Swift **6.4**, Swift 6 language mode and complete concurrency checking.
- Deployment: **iOS 26.0+**. Updating the SDK does not raise the deployment target.
- Development lint: SwiftLint **0.65.1** (`brew install swiftlint`).
- Select Xcode per command using `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`; `.xcode-version` records the target.

Verified with stable Xcode 27.1 (27A9275) and bundled Swift 6.4. The StoreGenerator manifest requires Swift 6.4.

## Architecture

```text
App composition → feature screens → @MainActor @Observable ViewModels
                                            ↓
                         Domain repository protocols + value snapshots
                                            ↑
                        Core/Persistence SwiftData implementations
```

- `App/`: the composition root, concrete dependency wiring and independent navigation roots for Train, Log and Library. Screen state remains owned by its screen; navigation carries identifiers or detached values. The app shell retains each tab's navigation stack.
- `Domain/Models/`: `Sendable` value snapshots. Editing a snapshot cannot mutate a stored object. Collections are nonoptional; an independently deleted exercise reference can be absent.
- `Domain/Repositories/`: `@MainActor` async protocols. Writes accept complete aggregates; there is no separate child-deletion operation.
- `Domain/Services/`: generation, streak calculation and injected time. Pure services have no framework dependency beyond Foundation. Timers own observable state on the main actor.
- `Core/Persistence/`: unchanged SwiftData entity identities, explicit mapping and private-context repositories. Each write saves once and rolls back on failure. Production repositories have separate contexts with autosave disabled.
- `Features/`: screens, ViewModels and local components. Shared visual primitives and fixed design tokens live in `Shared/`. One type per file; no generic repository or coordinator hierarchy.

To add a feature, start with domain inputs/outputs, add only the needed repository operation, update its SwiftData, preview and mock implementations, then add a ViewModel and screen. Compose dependencies in `AppComposition`; do not import persistence into a feature. Run the boundary check before committing.

## Persistence and workout lifecycle

The bundled `default.store` is copied only when the destination does not exist. Existing user stores are never replaced. Persistent class names, fields and relationships are preserved; this refactor needs no schema migration. The generator's model definitions mirror the app's persistence schema and must be changed together when an intentional schema migration is introduced.

Workout edits are detached drafts. Replacing children and editing the parent is one repository write. References to missing catalog entries fail the write and roll back. A missing optional reference already stored in a workout maps to `nil`.

An active workout has one session UUID and explicit idle/saving/saved/failed states. Completion and retry use the same UUID; the repository upserts it. A failed save keeps the completion screen open for retry. Successful completion refreshes history. Elapsed and rest times use wall-clock deadlines, so time spent in the background counts; cancellation prevents further ticks.

## Validation

Before adding or replacing YouTube demonstrations in **either app**, complete the mandatory [video checklist](Scripts/ExerciseMedia/CHECKLIST.md) and retain dated evidence. The [OnlyWeights candidate review](Scripts/ExerciseMedia/Reviews/2026-10-25/REPORT.md) and [OnlyBody audit](Scripts/ExerciseMedia/Reviews/2026-10-24/REPORT.md) distinguish code checks, per-video Embed availability and unresolved privacy/device/content review items. Automated validation does not certify these manual checks.

```sh
DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro' Scripts/validate.sh
```

The script checks architectural boundaries, both generated catalogs and bundled seed contents, SwiftLint, all tests and a Release simulator build for each product, bundle resource isolation and temporary generation of both seed stores. It stores `.xcresult`, screenshots attached on UI failures and build artifacts under a unique `/tmp` directory. Set `VALIDATION_OUTPUT` to retain them elsewhere. `ALLOW_OLDER_XCODE=1` explicitly permits compatibility checks on an older toolchain, but skips Swift 6.4 generator validation and does not establish target-toolchain support.

- Unit and integration tests: Swift Testing in `onlybodyTests` and `onlyweightsTests`.
- E2E: XCTest + XCUIAutomation only in `onlybodyUITests` and `onlyweightsUITests`. Five journeys cover creation/relaunch, editing, completion/history, early completion and navigation.
- Each E2E test starts with a unique UUID via the Debug-only `ONLYBODY_UI_STORE` environment variable and `ONLYBODY_UI_FIXTURE=catalog`. The app copies the real bundled catalog into `Documents/UITests/<UUID>/default.store`; the test uses real repositories. Relaunching retains that store. Production builds ignore this setting.
- UI automation uses accessibility identifiers and bounded state waits. Unit timer tests use a manual clock instead of real delays.
- Persistence tests open a copied bundled store, write data using the original model schema and reopen through the new domain boundary. They also exercise rollback, detached reads and session idempotency.
- Inspect screen previews in Xcode and smoke-test Create → Edit → Start → Log on a simulator before release. Automated journeys do not replace visual review.

Run a single suite with `xcodebuild test -project onlybody/onlybody.xcodeproj -scheme onlybody -destination "$DESTINATION" -only-testing:onlybodyUITests`.

## Seed generation

Use the target Swift toolchain and a new output path when validating:

```sh
swift run --package-path Scripts/StoreGenerator StoreGenerator \
  /tmp/onlybody-new.store Scripts/StoreGenerator/SeedData.json
```

For OnlyWeights use `Scripts/StoreGenerator/OnlyWeights/SeedData.json` and an independent output path. Shipping seeds live under `onlybody/Products/<Product>/Resources/SeedStore/default.store`; WAL/SHM sidecars are excluded from builds. See `Scripts/StoreGenerator/README.md` for metadata regeneration commands.

Only replace the bundled store as part of an intentional catalog update. No runtime JSON parsing or bulk catalog insertion is used by the shipping app.

### OnlyWeights rename — 24 October 2026

The gym product is now OnlyWeights: scheme/module `onlyweights`, Bundle ID `ikhvost.onlyweights`, compile condition `ONLYWEIGHTS`, product folders `OnlyWeights`, and an OW monogram for its icon and launch artwork. Exercise content and the OnlyBody product are unchanged.

After renaming, all 172 OnlyWeights and 199 OnlyBody Swift Testing tests passed, along with OnlyWeights' create/relaunch UI journey. Both Release builds, bundle identity/resource checks, lint, generated catalogs and architecture checks passed. Rename validation artifacts are in `/tmp/onlyweights-rename/`.

### Historical two-product verification — 24 October 2026

These results were recorded before the gym product was renamed from OnlyGym to OnlyWeights.

On Xcode 27.1 / Swift 6.4 with iPhone 17 Pro / iOS 26.4.1, the complete two-product validation passed:

- OnlyBody: 199 Swift Testing tests and all five E2E journeys.
- OnlyGym: 172 Swift Testing tests and the same five E2E journeys.
- Both Release simulator builds, zero SwiftLint violations, architecture checks, catalog checks, bundle identity/resource isolation and temporary generation of 65/16 exercises.
- OnlyBody's seed, icon and launch artwork remain byte-identical to the previous revision. Existing-store upgrade tests passed without changing the persistence schema or production store location.
- On a separate temporary simulator, both Debug apps stayed alive with `XCODE_RUNNING_FOR_PREVIEWS=1` and created no store. Launching both with the same test-store UUID produced distinct sandbox databases with their respective catalogs; a write to the disposable OnlyBody database did not change OnlyGym. The temporary simulator was removed afterward.
- Visual review confirmed distinct OB/OG home-screen icons, the OnlyGym title and the Lat Pulldown muscle map with its no-video state. The OG launch artwork was inspected; both products use the unchanged launch storyboard layout. The additional navigation run with a retained screenshot passed (`onlygym-Visual.xcresult`).
- Validation artifacts: `/tmp/onlybody-onlygym-validation/`; storage/preview evidence: `ProductIsolation.json`. Navigation journeys retain a movement-details screenshot for future visual review.

### Verification recorded for this refactor

On Xcode 27.1 (27A9275) / Swift 6.4 with the iPhone 17 Pro iOS 26.4 simulator (24 October 2026):

- Debug test build and Release simulator build passed.
- 145 Swift Testing tests passed across 17 suites.
- All five E2E journeys passed in the same full validation run.
- SwiftLint strict mode, architecture boundaries and `git diff --check` passed.
- Temporary seed generation with Swift 6.4 produced 157 exercises.
- SwiftUI Canvas previews rendered and were visually inspected in Xcode 27.1: Train (empty/populated), Library, Log (empty/populated), Muscle Picker, Session Builder, Active Workout, Movement Detail and Session Detail. Simulator screenshots were also inspected for history navigation and session details.
- Additional iPhone Duo / iOS 27.1 verification: 145 Swift Testing tests and all five E2E journeys passed. The initial UI runner launch failed during runtime setup; the subsequent E2E run passed after installation finished. Result: `/tmp/onlybody-xcode271-final/iOS271-Retry.xcresult`.
- Full validation artifacts: `/tmp/onlybody-xcode271-final/Tests.xcresult`; build and generator log: `/tmp/onlybody-xcode271-final.log`.

The app icon uses the existing 1024×1024 artwork as a universal iOS asset; Xcode generates the iPhone and iPad variants. Project-level `LM_SKIP_METADATA_EXTRACTION = YES` disables unused AppIntents metadata extraction for the app and test targets. Remove this setting when adding App Intents or App Shortcuts.

After the icon and metadata configuration cleanup, fresh Debug `build-for-testing` (app, unit and UI test targets) and Release simulator builds passed on Xcode 27.1 with zero build warnings or errors. Logs: `/tmp/onlybody-clean-warnings-debug.log` and `/tmp/onlybody-clean-warnings-release.log`. SwiftLint strict mode and architecture checks also passed. Tests were not rerun for this asset/build-setting-only change.
