# TASK-012 - Training Log

## Type

AFK

## User story

As a user, I can review completed sessions by month.

## What to build

Add the Log tab as a real session history screen backed by `SessionRepository`. This slice should make saved sessions visible and navigable.

Implement `LogViewModel` and `LogView`. Sessions should load from the repository, sort most recent first, group by month, show approved row content, display an empty state, and route to Session Detail.

## Acceptance criteria

- [ ] `LogViewModel` is `@Observable` and `@MainActor`.
- [ ] `LogViewModel` depends on `SessionRepository` protocol.
- [ ] `LogViewModel.load()` fetches sessions and exposes loading/error state.
- [ ] Sessions are displayed most recent first.
- [ ] Sessions are grouped by month.
- [ ] Month headers use uppercase month labels.
- [ ] Current-year month headers omit year if following the approved spec.
- [ ] Log header matches design: mono `TRAINING HISTORY`, title `Log`.
- [ ] Empty state appears when no sessions exist.
- [ ] Session rows show date square, workout name, weekday, duration, calories, and custom chevron icon.
- [ ] Duration display uses `MM:SS`.
- [ ] Calories display gracefully handles nil values.
- [ ] Tapping a row routes to Session Detail.
- [ ] Routing uses `navigationDestination(for:)`.
- [ ] `LogView` does not import SwiftData, use `@Query`, or access `ModelContext`.
- [ ] `LogViewModel` tests cover loading, error state, sorting, and month grouping.

## Blocked by

- TASK-011 - `docs/tasks/011-completed-session-save.md`

## Additional references

- `docs/design.html:L640-L674` - Prototype Log screen grouping, rows, date square, and navigation.
- `docs/design.html:L830-L853` - Prototype routing from Log row to Session Detail.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L377-L398` - Approved Log screen layout and grouping behavior.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L514-L530` - Approved Log to Session Detail navigation model.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L147-L176` - Session model fields shown in Log.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L180-L204` - Session repository API including recent sessions.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L252-L283` - Tab-specific NavigationStack and destination rules.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L286-L317` - ViewModel layer and SwiftData-free view constraints.

## Implementation notes

- Use stable route identifiers rather than passing SwiftData model instances through navigation when possible.
- Keep all date formatting in ViewModel or small pure helpers, not scattered through row views.
- Do not implement Session Detail content in this task beyond route hookup if TASK-013 is not present.
