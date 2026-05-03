---
name: onlybody-ios-review
description: Reviews changed OnlyBody iOS code for bugs, regressions, architecture violations, SwiftUI/SwiftData/concurrency issues, design-spec drift, and missing tests, then suggests concrete fixes. Use when reviewing diffs, pull requests, staged changes, or feature edits in the OnlyBody app, especially for Swift, SwiftUI, SwiftData, navigation, repositories, view models, or screen-level UI changes.
---

# OnlyBody iOS Review

## Quick start

Review changed files first, then read the minimum surrounding context needed to judge behavior, architecture, and regression risk.

Return findings first:
1. Severity-ordered issues with `path:line`
2. Why each issue matters
3. Concrete fix direction

If no findings are discovered, say so explicitly and note residual risks or testing gaps.

## Workflow

1. Read the diff or changed files.
2. Read adjacent types, protocols, and call sites needed to understand impact.
3. If any UI is affected, first read `AGENTS.md`, `DOCUMENTATION_AND_RULES.md`, and `APPLICATION_CHANGE_CONTEXT.md`. Read `docs/archive/mvp/design.html` and archived MVP design docs only when the task requires historical design parity or drift review.
4. Review against OnlyBody rules before giving style feedback.
5. Prioritize bugs, behavior regressions, and architecture violations over nits.
6. Keep the summary brief and secondary to findings.

## What to check

### Architecture

- Views depend only on their view model.
- No `@Query`, `ModelContext`, or SwiftData imports in views.
- View models are `@Observable` and `@MainActor`.
- View models depend on repository protocols, not concrete SwiftData implementations.
- No view-model-to-view-model dependencies.
- Shared components stay reusable and do not absorb screen logic.

### SwiftUI

- No `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, or `@EnvironmentObject`.
- Use `NavigationStack` plus `navigationDestination(for:)`; no `NavigationLink`.
- No `TabView` for app tabs.
- No `onTapGesture()` when `Button` should be used.
- No `GeometryReader`, `AnyView`, or `UIScreen.main.bounds` unless clearly justified.
- Prefer `foregroundStyle()` and `clipShape(.rect(cornerRadius:))`.
- Preserve the custom visual system instead of default iOS styling.

### Theme and design

- No hardcoded colors, font sizes, or spacing where `Theme` should be used.
- Use `Theme.fontSans` and `Theme.fontMono`.
- Flag drift from current active repo rules first. If the task is about historical MVP fidelity, also compare against the archived MVP prototype, written spec, custom navigation, typography, icons, and spacing rules.

### SwiftData

- Models have defaults or optional stored properties.
- Relationship optionality and delete rules match deletion behavior.
- Repository boundaries stay intact.
- Persistence logic does not leak into views or view models.

### Concurrency and Swift

- Respect strict concurrency and actor isolation.
- No `DispatchQueue.main.async()` where async/await should be used.
- No force unwraps or force `try` unless truly unrecoverable.
- Prefer modern Swift and Foundation APIs required by repo rules.

### Testing

- Flag missing unit tests for changed services and view models.
- Flag behavior changes without enough coverage.
- Note when repository changes should have in-memory integration tests.

## Output format

For each finding include:
- Severity
- `path:line`
- Problem
- Why it matters
- Suggested fix

If there are no findings:
- State that explicitly
- Mention remaining risk areas
- Mention missing verification if build or tests were not checked
