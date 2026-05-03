# TASK-015 - MVP Integration Hardening And Design Review

## Type

HITL

## User story

As a user, I get a cohesive MVP where all core flows work together and match the approved OnlyBody design.

## What to build

Run a final integration and acceptance pass across the full MVP. This slice is intentionally HITL because it includes visual/design review against the prototype and a final product-quality judgment.

Verify that all vertical slices work together: launch, seed, catalog, movement detail preferences, custom movement creation, manual workout creation, smart workout creation, Train scheduling, active workout execution, session save, Log, Session Detail, and Streak. Fix integration gaps, remove temporary placeholders that should no longer exist, and ensure tests/build pass cleanly.

## Acceptance criteria

- [ ] App builds cleanly with Swift 6.2 strict concurrency.
- [ ] All unit and integration tests pass.
- [ ] No SwiftLint warnings or errors remain if linting is configured.
- [ ] App launches into Train with custom bottom navigation.
- [ ] Seeded Library appears on first launch with no duplicates after relaunch.
- [ ] Library search and filters work.
- [ ] Movement Detail displays real exercise metadata and persists frequency preference changes.
- [ ] Custom Exercise Form saves a custom movement that appears in Library.
- [ ] Manual Session Builder creates a saved workout visible on Train.
- [ ] Smart Muscle flow creates a saved smart workout visible on Train.
- [ ] Train day strip and today callout reflect scheduled workouts.
- [ ] Active Workout can be started from Train and completed end to end.
- [ ] Rest overlay counts down and can be skipped.
- [ ] Completed workout saves a session.
- [ ] Saved session appears in Log.
- [ ] Session Detail shows saved per-set breakdown.
- [ ] Streak screen reflects actual session history.
- [ ] Bottom nav hides on pushed sub-screens and reappears at tab roots.
- [ ] No views import SwiftData.
- [ ] No views use `@Query` or `ModelContext`.
- [ ] No `ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, or `@EnvironmentObject` are used.
- [ ] No SwiftUI `TabView`, `Tab`, `tabItem`, or `NavigationLink` are used.
- [ ] No SF Symbols are used for app icons.
- [ ] No hardcoded colors, font sizes, or spacing values remain in views where `Theme` should be used.
- [ ] Human reviewer compares all MVP screens against `docs/design.html` and `docs/plans/2026-05-01-bodyweight-training-design.md`.
- [ ] Human reviewer approves visual fidelity or files follow-up issues for any accepted deviations.

## Blocked by

- TASK-001 - `docs/tasks/001-app-shell-and-design-system-smoke-test.md`
- TASK-002 - `docs/tasks/002-seeded-movement-persistence-tracer.md`
- TASK-003 - `docs/tasks/003-searchable-movement-catalog.md`
- TASK-004 - `docs/tasks/004-movement-detail-preferences.md`
- TASK-005 - `docs/tasks/005-custom-movement-creation.md`
- TASK-006 - `docs/tasks/006-workout-persistence-and-train-list.md`
- TASK-007 - `docs/tasks/007-manual-session-builder.md`
- TASK-008 - `docs/tasks/008-smart-muscle-session-builder.md`
- TASK-009 - `docs/tasks/009-scheduled-train-home.md`
- TASK-010 - `docs/tasks/010-active-workout-set-tracking.md`
- TASK-011 - `docs/tasks/011-completed-session-save.md`
- TASK-012 - `docs/tasks/012-training-log.md`
- TASK-013 - `docs/tasks/013-session-detail.md`
- TASK-014 - `docs/tasks/014-streak-insights.md`

## Additional references

- `docs/design.html:L22-L873` - Full interactive prototype covering tokens, components, screens, navigation, and screen-specific behavior.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L10-L544` - Full approved visual design spec, components, screen layouts, navigation model, and motion rules.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L12-L463` - Full approved technical architecture, data model, repositories, navigation, services, error handling, and testing strategy.

## Implementation notes

- This is the only HITL slice in the MVP breakdown.
- Do not broaden the MVP during this pass; file follow-up issues for enhancements.
- Prioritize correctness, architecture compliance, visual fidelity, and test stability.
- Do not close or modify any parent plan document as part of this task.
