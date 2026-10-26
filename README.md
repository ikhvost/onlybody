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

## Maintenance

- [Catalog and seed generation](Scripts/StoreGenerator/README.md)
- [YouTube catalogs and review status](Scripts/ExerciseMedia/README.md) · [mandatory review checklist](Scripts/ExerciseMedia/CHECKLIST.md)
- [Muscle artwork and classification](Scripts/MuscleDiagrams/README.md)
- [App icons and launch assets](Scripts/AppIcon/README.md)
- [Website editing, assets and deployment](Website/README.md)
