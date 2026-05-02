# TASK-011 - Completed Session Save

## Type

AFK

## User story

As a user, my completed workout is saved as training history.

## What to build

Add the session persistence path that turns active workout completion data into saved training history. This slice completes the path from workout execution to durable `Session` and `SessionItem` records.

Create `Session` and `SessionItem` SwiftData models, `SessionRepository` protocol, `SwiftDataSessionRepository`, and Active Workout save behavior. A completed session should include duration, calories, workout name snapshot, ordered session items, planned sets/reps, actual set reps, and weight.

## Acceptance criteria

- [x] `Session` is a SwiftData `@Model` in its own file.
- [x] `SessionItem` is a SwiftData `@Model` in its own file.
- [x] `Session.id` uses `@Attribute(.unique)`.
- [x] `Session` includes date, duration seconds, optional calories burned, workout name snapshot, and optional items relationship.
- [x] `SessionItem` includes id, order, exercise name snapshot, planned sets, planned reps, set reps, and optional weight kg.
- [x] All non-optional model properties have defaults.
- [x] `SessionRepository` exposes `allSessions`, `recentSessions(limit:)`, and `save`.
- [x] `recentSessions(limit:)` returns most recent sessions first and respects fetch limit.
- [x] Completing the final set creates and saves exactly one `Session`.
- [x] Saved session uses workout name snapshot so it survives future workout deletion.
- [x] Saved session items use exercise name snapshots so they survive future exercise deletion.
- [x] Saved session item order matches workout item order.
- [x] Saved `setReps` length matches completed sets for each movement.
- [x] Saved weight uses the active workout weight value for each movement where applicable.
- [x] Calories use the approved rough estimate from elapsed minutes.
- [x] Save failures surface through `ActiveWorkoutViewModel.errorMessage`.
- [x] Ending a session intentionally saves available completed data if the approved behavior in the current implementation plan requires it.
- [x] In-memory repository tests cover session save/fetch and recent limit.
- [x] Active Workout ViewModel test verifies session save on completion.

## Blocked by

- TASK-010 - `docs/tasks/010-active-workout-set-tracking.md`

## Additional references

- `docs/design.html:L299-L436` - Prototype Active Session completion flow that triggers session save.
- `docs/design.html:L640-L703` - Prototype Log and Session Detail screens that consume saved sessions.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L204-L263` - Approved Active Session completion behavior.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L377-L425` - Approved Log and Session Detail saved-session displays.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L147-L176` - Approved `Session` and `SessionItem` models and snapshot decisions.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L180-L204` - Session repository protocol and SwiftData implementation boundary.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L444-L463` - Error handling and test strategy for persistence.

## Implementation notes

- Keep repository implementation SwiftData-specific and ViewModel repository-protocol-specific.
- Avoid force unwraps when reading optional workout items or exercises.
- If partial-session behavior is ambiguous during implementation, ask one short question before changing the intended behavior.
- Do not build Log UI in this task; saved sessions can be verified through tests or temporary diagnostics.
