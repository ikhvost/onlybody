# AGENTS.md — OnlyBody

## Start Here

Before doing non-trivial work, read these files in repo root:

1. `DOCUMENTATION_AND_RULES.md`
2. `APPLICATION_CHANGE_CONTEXT.md`

Do not treat archived MVP planning docs as active instructions unless the task explicitly asks for historical behavior or design verification.

## Project Overview

OnlyBody is an iOS bodyweight training app built with SwiftUI and SwiftData.

- Single-user
- On-device only
- No CloudKit
- No third-party dependencies
- iOS 26.0+
- Swift 6.2 with strict concurrency

## Scope Discipline

Work only on the asked task or tasks.

- Do not broaden scope on your own.
- Do not revive archived plans as mandatory requirements.
- If a task conflicts with current docs, follow `DOCUMENTATION_AND_RULES.md` and `APPLICATION_CHANGE_CONTEXT.md`.
- If a task conflicts with shipped code behavior, inspect the code and ask one short question before making a high-risk change.

## Current Working Context

The repo is no longer in MVP planning mode.

- `AGENTS.md` gives evergreen repo-level engineering rules.
- `DOCUMENTATION_AND_RULES.md` explains which docs are active, which are archived, and how agents should use them.
- `APPLICATION_CHANGE_CONTEXT.md` describes the current architecture, target structure, migration direction, and practical constraints for future work.
- `docs/archive/mvp/` contains historical MVP design, tech, and task documents. Use them only as reference.

## Architecture Rules

Target interaction flow remains:

```text
View -> ViewModel (@Observable @MainActor) -> Repository protocol -> SwiftData repository
```

Rules:

- Views depend on their view model or explicit screen inputs only.
- No `@Query`, `ModelContext`, or SwiftData imports in views.
- View models must be `@Observable` and `@MainActor`.
- View models depend on repository protocols, not concrete SwiftData implementations.
- No view-model-to-view-model dependencies.
- Services are pure logic units. No SwiftUI. No SwiftData.
- `Theme.swift` is the source of truth for visual tokens used in code.

Important current-state nuance:

- The codebase already uses repository protocols, but many view models and services still operate on SwiftData model types directly.
- Do not describe or assume the app is already fully domain-decoupled from persistence.
- Prefer incremental structure improvements over a full architecture rewrite.

## Navigation Rules

- Do not use SwiftUI `TabView` for app tabs.
- Use `NavigationStack` and `navigationDestination(for:)`.
- Do not use `NavigationLink` for app flow.
- `ActiveWorkoutView` should stay behind `fullScreenCover` unless the task intentionally changes workout flow.

## Swift Rules

- No `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, or `@EnvironmentObject`.
- No `DispatchQueue.main.async()` where async/await is appropriate.
- No force unwraps or force `try` unless failure is unrecoverable.
- Prefer modern Foundation and Swift APIs.
- Prefer `Task.sleep(for:)` over `Task.sleep(nanoseconds:)`.
- Use `localizedStandardContains()` for user-facing search matching.

## SwiftUI Rules

- Use `foregroundStyle()` over `foregroundColor()`.
- Use `clipShape(.rect(cornerRadius:))` over `cornerRadius()`.
- No single-parameter `onChange()`.
- No `UIScreen.main.bounds`.
- No `AnyView` unless clearly necessary.
- No `GeometryReader` unless clearly necessary.
- No `onTapGesture()` where `Button` is the correct control.
- Use `Theme.fontSans` and `Theme.fontMono` instead of system text styles.
- Use theme-based spacing and colors instead of introducing new ad hoc visual values.

## SwiftData Rules

- On-device only. `@Attribute(.unique)` is allowed where appropriate.
- All model properties need defaults or optionals.
- Relationships must reflect deletion behavior explicitly.
- Persistence logic belongs in repositories, not views.

## Testing Rules

- Unit-test services.
- Unit-test view models with mock repositories.
- Integration-test repository behavior with in-memory `ModelContainer` where repository behavior changes.
- Do not add UI tests unless the task requires them.

## Documentation Usage

- Do not require `docs/archive/mvp/design.html` or old plan docs for every UI task.
- Consult archived MVP docs only when:
  - a task explicitly asks for parity with the original MVP design,
  - you need to confirm an old product decision,
  - or you are reviewing historical drift.
- When current code and archived docs differ, prefer current active docs unless the task says otherwise.

## Code Quality

- Prefer the smallest correct change.
- Keep ownership clear.
- Avoid turning `Shared` into a dumping ground.
- Co-locate feature-specific code with its feature when touching structure.
- Add concise comments only when they save real reader time.
- No secrets in the repository.

## Current Refactor Direction

The next structural direction is feature-first organization with a thin app shell.

- `AppTabView` should trend toward a shell, not a multi-feature orchestration file.
- Navigation ownership should gradually move toward feature flow views.
- Views and view models for the same feature should be co-located over time.
- `Shared` should contain only truly shared UI and infrastructure.

See `APPLICATION_CHANGE_CONTEXT.md` for the detailed migration direction.
