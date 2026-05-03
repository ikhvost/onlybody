# OnlyBody

OnlyBody is an iOS bodyweight training app built with SwiftUI and SwiftData.

The MVP is implemented. The repository is now in a cleanup and next-iteration phase focused on documentation reset, structure improvement, and incremental architecture refinement.

## Stack

- iOS 26.0+
- Swift 6.2 with strict concurrency
- SwiftUI
- SwiftData
- On-device storage only
- No third-party dependencies

## Read First

For current context, read these files in order:

1. `AGENTS.md`
2. `DOCUMENTATION_AND_RULES.md`
3. `APPLICATION_CHANGE_CONTEXT.md`

These files are the active working context for future engineering tasks.

## Archived MVP Docs

The original MVP planning artifacts were archived to:

- `docs/archive/mvp/design.html`
- `docs/archive/mvp/plans/`
- `docs/archive/mvp/tasks/`

They are historical reference only. Do not treat them as mandatory prereads unless a task explicitly requires historical MVP parity.

## Current Architecture Summary

Current mental model:

```text
View -> ViewModel (@Observable @MainActor) -> Repository protocol -> SwiftData repository
```

Important current-state nuance:

- views are already feature-grouped
- view models are still mostly flat
- `AppTabView` currently owns too much orchestration
- repository abstraction exists, but many layers still use SwiftData model types directly

See `APPLICATION_CHANGE_CONTEXT.md` for the detailed structure and migration direction.

## App Location

The Xcode project and app source live under:

```text
onlybody/
```

Open:

```text
onlybody/onlybody.xcodeproj
```

## Working Principles

- Prefer small, correct changes.
- Keep feature ownership clear.
- Avoid growing `Shared` with feature-specific code.
- Preserve the repository boundary.
- Do not introduce third-party dependencies.
- Use `Theme.swift` for visual tokens already represented in code.

## Next Direction

The next structural direction is:

- a thinner app shell
- explicit app dependency construction
- feature-local flow ownership
- feature-first file organization
- smaller and stricter shared surface area

This is an incremental migration direction, not a mandate for a full rewrite.
