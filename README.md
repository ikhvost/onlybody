# OnlyBody & OnlyWeights

Two iOS apps sharing SwiftUI and SwiftData code, with independent on-device stores and no third-party app dependencies.
The repository folder is `onlybody`; `Apps/iOS` contains both iOS products. `Website`, `Scripts` and `Design` are siblings of `Apps` at the repository root.

## Development

Open `Apps/iOS/Apps.xcodeproj` and select `onlybody` or `onlyweights`.
Use Xcode 27.1 / Swift 6.4, iOS 26.0+, and SwiftLint 0.65.1 (`brew install swiftlint`).
Coding, architecture, navigation and testing rules live in [AGENTS.md](AGENTS.md).

| Location | Purpose |
| --- | --- |
| `Apps/iOS/Sources/` | Shared app, domain, persistence, features and design system |
| `Apps/iOS/Products/{OnlyBody,OnlyWeights}/` | Product catalogs, seed stores and branding |
| `Apps/iOS/Configuration/` | Shared build settings and product identities |
| `Apps/iOS/Tests/`, `Apps/iOS/ProductTests/` | Shared and product-specific Swift Testing suites |
| `Apps/iOS/UITests/` | Shared functional UI tests and opt-in visual captures |
| `Apps/iOS/Configuration/TestPlans/` | Functional (default) and Visual plans for each scheme |
| `Website/dist/` | Static website, Privacy Policy and Terms |

Bundle IDs: `ikhvost.onlybody` and `ikhvost.onlyweights`. Both apps use `Documents/default.store` in separate sandboxes. Preserve existing model identities and user stores.

## Smart Selection

Smart starts with muscle groups, followed by duration, equipment and injury-region restrictions. It accepts one preset (`Full Body`, `Upper`, or `Lower`) or up to three individual muscle groups. The generated daily list opens in the same editor as a manual workout, with guides, adding/removing exercises, unrestricted replacement, ordering and editable sets, reps and rest.

Automatic selection respects equipment, injury regions and legacy load restrictions. Coverage uses primary muscles. Sets range from 2–3; defaults are 3 × 10 with 90 seconds rest for main exercises and 2 × 12 with 60 seconds rest for accessories. There is no difficulty setting or permanent exercise exclusion. The generator still aims for the requested duration and retains its daily variation and main-exercise anchors.

Manual edits apply only to the reviewed day. Any nonempty list with valid numbers can be saved or started, regardless of duration, original targets, equipment or injury restrictions. No short-plan confirmation is required and the editor never trims the list. Opening or editing does not write; Save/Start commits the workout and daily payload atomically. An open editor retains its day across midnight; a fresh opening resolves the new local day. Active sessions use a detached reviewed snapshot.

The SwiftData schema and existing stores remain unchanged. Legacy level, excluded-exercise and acceptance fields are retained for payload compatibility but no longer control behavior. Cached lists, schedule, history and restriction settings remain available.

## Validation

Run from the repository root:

```sh
python3 Scripts/Validation/check-boundaries.py
python3 Scripts/Validation/check-catalogs.py
DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro' Scripts/validate.sh quick
DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro' Scripts/validate.sh full
```

`quick` runs lint, validator regression tests, catalog/boundary/localization checks, and unit/integration tests for both products. `full` (also the default with no argument) adds functional UI tests, Release simulator builds, bundle isolation checks and temporary seed generation. Both modes explicitly select the Functional test plan; neither creates visual screenshot sets. Results go to a unique `/tmp/apps-validation-*` directory; override with `VALIDATION_OUTPUT`. Select another Xcode with `DEVELOPER_DIR` if needed.

Functional UI coverage includes the five workout journeys, language selection/search and control hit areas. Explicit screenshots are retained only for failed functional tests; Xcode's own diagnostics remain enabled. HTML design references remain in `Design/`.

### Optional screenshots

Both schemes default to **Functional** in Xcode. Choose **Visual** only to create requested images. The existing store, release and design capture suites remain available; select just the suite you need. For example:

```sh
xcodebuild test -project Apps/iOS/Apps.xcodeproj -scheme onlybody \
  -testPlan Visual -only-testing:onlybodyUITests/StoreScreenshotTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -parallel-testing-enabled NO -resultBundlePath /tmp/OnlyBody-StoreScreenshots.xcresult
```

Use a new result path for each run. For OnlyWeights, change the scheme to `onlyweights` and test target to `onlyweightsUITests`. Select `NativeDesignReviewTests` for the screen matrix or `ReleasePreparationTests` for the existing release capture flow. Export store images with `Scripts/Release/export-screenshots.py`. Ordinary validation and archive preparation never select Visual; screenshots required by a specific media review or publication task remain a separate workflow.

### Catalog compatibility

Canonical exercise names are persisted lookup keys. `Scripts/StoreGenerator/CatalogKeys.json` is an append-only registry for each product: explicitly register new names, and never remove or rename an existing key during routine catalog editing. Generators do not update this registry. Renaming or retiring a canonical key requires a separate compatibility plan; change display wording through translations instead.

Each product supplies its own `ExerciseLocalizationCatalog` table. The shared `CatalogLocalization.exercise(_:locale:)` API and `Localizable.xcstrings` remain shared, as do muscle/equipment labels. Product names and compile-time flags belong at the composition boundary, not inside feature or domain logic.

## Release archives

Use the release script from the repository root for either product:

```sh
DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro' \
  Scripts/Release/prepare.sh onlybody 1.2.0 42
DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro' \
  Scripts/Release/prepare.sh onlyweights 1.2.0 42
```

Arguments are the scheme, three-component marketing version and positive integer build number (1–9999). Choose a new build number for each upload. The script requires the exact Xcode in `.xcode-version`, SwiftLint and an installed simulator. It always runs `Scripts/validate.sh full` for both products before archiving the selected app for iPhone. Version overrides apply only to the archive; tracked configuration and bundled seed stores are not rewritten.

If Xcode cannot resolve the simulator by name, use `DESTINATION='platform=iOS Simulator,id=<simulator UUID>'`. Find available destinations with `xcodebuild -showdestinations -project Apps/iOS/Apps.xcodeproj -scheme onlybody`; use the simulator ID, not a physical device ID.

Signing uses the project's automatic signing and configured team. Install the required signing identity and provisioning profile in advance, or set `ALLOW_PROVISIONING_UPDATES=1` to let Xcode manage provisioning using an authenticated Xcode account. An archive may use a development signing identity; App Store distribution signing happens during export/distribution in Organizer.

Artifacts are retained in a unique gitignored `Release/<product>-<version>-<build>-*` directory: validation results, logs, build provenance, `Archive.xcresult` and `<product>.xcarchive`. Set `RELEASE_OUTPUT` to a new directory to choose another location; existing directories are rejected. A `PREPARED` marker is written only after validation, archive metadata checks and signature verification succeed. Failed runs retain their diagnostics without this marker.

Open the archive in Xcode Organizer to distribute it. This script does not export an IPA, upload to Apple or submit for review. Automated success does not complete the [manual YouTube release checklist](Scripts/ExerciseMedia/CHECKLIST.md), physical-device playback review or App Store metadata preparation.

## Maintenance

- [Version and build history](CHANGELOG.md)
- [Marketing copy, artwork templates and localization](Assets/Marketing/README.md)
- [Catalog and seed generation](Scripts/StoreGenerator/README.md)
- [YouTube catalogs and review status](Scripts/ExerciseMedia/README.md) · [mandatory review checklist](Scripts/ExerciseMedia/CHECKLIST.md)
- [Muscle artwork and classification](Scripts/MuscleDiagrams/README.md)
- [App icons and launch assets](Scripts/AppIcon/README.md)
- [Website editing, assets and deployment](Website/README.md)
