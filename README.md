# OnlyBody & OnlyWeights

Two iOS apps sharing SwiftUI and SwiftData code, with independent on-device stores and no third-party app dependencies.

## Development

Open `onlybody/onlybody.xcodeproj` and select `onlybody` or `onlyweights`.
Use Xcode 27.1 / Swift 6.4, iOS 26.0+, and SwiftLint 0.65.1 (`brew install swiftlint`).
Coding, architecture, navigation and testing rules live in [AGENTS.md](AGENTS.md).

| Location | Purpose |
| --- | --- |
| `onlybody/onlybody/` | Shared app, domain, persistence, features and design system |
| `onlybody/Products/{OnlyBody,OnlyWeights}/` | Product catalogs, seed stores and branding |
| `onlybody/Configuration/` | Shared build settings and product identities |
| `onlybody/onlybodyTests/`, `onlybody/ProductTests/` | Shared and product-specific Swift Testing suites |
| `onlybody/onlybodyUITests/` | Five shared XCTest UI journeys |
| `Website/dist/` | Static website, Privacy Policy and Terms |

Bundle IDs: `ikhvost.onlybody` and `ikhvost.onlyweights`. Both apps use `Documents/default.store` in separate sandboxes. Preserve existing model identities and user stores.

## Validation

Run from the repository root:

```sh
python3 Scripts/Validation/check-boundaries.py
python3 Scripts/Validation/check-catalogs.py
DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro' Scripts/validate.sh
```

Full validation runs lint, catalog/boundary checks, tests and Release simulator builds for both products, bundle isolation checks and temporary seed generation. Results go to a unique `/tmp/onlybody-validation-*` directory; override with `VALIDATION_OUTPUT`. Select another Xcode with `DEVELOPER_DIR` if needed.

## Release archives

Use the release script from the repository root for either product:

```sh
DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro' \
  Scripts/Release/prepare.sh onlybody 1.2.0 42
DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro' \
  Scripts/Release/prepare.sh onlyweights 1.2.0 42
```

Arguments are the scheme, three-component marketing version and positive integer build number (1–9999). Choose a new build number for each upload. The script requires the exact Xcode in `.xcode-version`, SwiftLint and an installed simulator. It always runs `Scripts/validate.sh` for both products before archiving the selected app for iPhone. Version overrides apply only to the archive; tracked configuration and bundled seed stores are not rewritten.

If Xcode cannot resolve the simulator by name, use `DESTINATION='platform=iOS Simulator,id=<simulator UUID>'`. Find available destinations with `xcodebuild -showdestinations -project onlybody/onlybody.xcodeproj -scheme onlybody`; use the simulator ID, not a physical device ID.

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
