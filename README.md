# OnlyBody

OnlyBody is an iOS bodyweight training app built with SwiftUI and SwiftData. The product direction, architecture, and visual system are already defined in the planning docs; the checked-in app target is still in early implementation.

## Status

- MVP direction is approved in `docs/plans/`
- The current Xcode target still contains mostly starter scaffold code
- The source of truth for future implementation is the design prototype and planning documents, not the default SwiftUI template files

## Stack

- iOS 26.0+
- Swift 6.2 with strict concurrency
- SwiftUI
- SwiftData
- On-device storage only, no CloudKit
- No third-party dependencies

## Source Of Truth

Read these before making UI or architecture changes:

1. `docs/design.html`
2. `docs/plans/2026-05-01-bodyweight-training-design.md`
3. `docs/plans/2026-05-01-bodyweight-training-tech.md`
4. `docs/plans/2026-05-01-onlybody-implementation-tasks.md`
5. `docs/tasks/README.md`

The visual system is fully custom:

- Dark-only interface
- DM Sans and DM Mono typography
- Amber accent `#E8A23A`
- Custom icons instead of SF Symbols
- Custom bottom navigation instead of SwiftUI `TabView`

## Architecture

Target architecture:

```text
View -> ViewModel (@Observable @MainActor) -> Repository protocol -> SwiftData repository
```

Core rules:

- Views read from view models only
- View models depend on repository protocols, not concrete SwiftData types
- Services contain pure logic and avoid SwiftUI and SwiftData
- `Shared/Theme/Theme.swift` is the single source of truth for design tokens
- Navigation uses `NavigationStack` and `navigationDestination(for:)`
- `ActiveWorkoutView` should be presented with `fullScreenCover`

## Repository Layout

Current repository structure:

```text
.
├── onlybody/                 # Xcode project and targets
├── docs/                     # design, technical plans, and task breakdowns
├── AGENTS.md                 # repo-specific engineering instructions
├── .gitignore
└── README.md
```

Planned app structure is documented in `docs/plans/2026-05-01-bodyweight-training-tech.md`.

## Getting Started

1. Open `onlybody/onlybody.xcodeproj` in Xcode.
2. Select the `onlybody` app target.
3. Build and run on an iOS 26.0+ simulator.
4. Use the planning docs to guide any non-trivial implementation work.

## Development Notes

- Do not treat the current template views as product direction.
- Keep changes aligned with the approved design spec and technical plan.
- Prefer small, focused changes.
- Do not add third-party dependencies.
- Keep all design tokens centralized in `Theme.swift` once the design system is implemented.

## Documentation Index

- Design prototype: `docs/design.html`
- Design spec: `docs/plans/2026-05-01-bodyweight-training-design.md`
- Technical plan: `docs/plans/2026-05-01-bodyweight-training-tech.md`
- Implementation breakdown: `docs/plans/2026-05-01-onlybody-implementation-tasks.md`
- Task index: `docs/tasks/README.md`
