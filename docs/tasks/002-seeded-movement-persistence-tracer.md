# TASK-002 - Seeded Movement Persistence Tracer

## Type

AFK

## User story

As a user, I have a built-in bodyweight movement library available on first launch.

## What to build

Add the first real data-backed path in the app: seeded exercises appear in the Library tab. This slice should prove SwiftData setup, repository injection, one-shot seed import, and a simple UI read path end to end.

Create the `Exercise` SwiftData model, `ExerciseRepository` protocol, `SwiftDataExerciseRepository`, `Repositories` environment value, `SeedData.json`, and `SeedManager`. Wire the app entry point to create a `ModelContainer`, inject repositories, seed exercises once, and render a simple repository-backed Library placeholder with real exercise names.

## Acceptance criteria

- [ ] `Exercise` is a SwiftData `@Model` in its own file.
- [ ] `Exercise.id` uses `@Attribute(.unique)`.
- [ ] `Exercise` has default values for all non-optional properties.
- [ ] `Exercise` includes name, primary muscle, secondary muscles, equipment, frequency preference, custom flag, created date, and optional workout item relationship.
- [ ] `ExerciseRepository` exposes `allExercises`, `exercises(primaryMuscle:)`, `exercises(matching:)`, `save`, and `delete`.
- [ ] `SwiftDataExerciseRepository` is isolated to the main actor and accepts `ModelContext` through its initializer.
- [ ] `allExercises()` fetches exercises sorted by name.
- [ ] Name matching uses `localizedStandardContains`, not `contains`.
- [ ] `Repositories` is injected through SwiftUI environment.
- [ ] `BodyweightApp` creates `ModelContainer` for the available models.
- [ ] `SeedData.json` includes at least 25 exercises.
- [ ] Seed data covers at least two exercises for each required muscle group from the approved task plan.
- [ ] Seed equipment values are limited to the approved set: `None`, `Dumbbells`, `Pull-up Bar`, `Resistance Bands`, `Kettlebell`, `Barbell`.
- [ ] `SeedManager` imports seed data only when the `didSeedExercises` flag is false.
- [ ] Relaunching the app does not duplicate seeded exercises.
- [ ] Library placeholder renders real seeded exercises from `ExerciseRepository`.
- [ ] Views do not import SwiftData and do not use `@Query` or `ModelContext`.
- [ ] In-memory repository integration test verifies exercise save and fetch behavior.

## Blocked by

- TASK-001 - `docs/tasks/001-app-shell-and-design-system-smoke-test.md`

## Additional references

- `docs/design.html:L76-L92` - Prototype movement data shape and sample movement catalog entries.
- `docs/design.html:L705-L748` - Prototype Library screen where seeded movements become visible.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L117-L119` - Exercise row visual requirements and custom badge styling.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L429-L451` - Library screen layout, search/filter placement, row behavior, and custom movement entry point.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L110-L124` - Approved `Exercise` SwiftData model fields and relationship.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L180-L204` - Repository protocol shape and SwiftData implementation responsibilities.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L208-L248` - App entry point, model container, repository injection, and no CloudKit requirement.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L436-L440` - Seed data import requirements.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L455-L463` - Repository integration test strategy.

## Implementation notes

- This task is the first app-wide dependency injection slice. Keep repository protocols separate from SwiftData implementations.
- Use one type per file.
- Keep the Library UI intentionally simple here; the full catalog UI belongs to TASK-003.
- Seed import can fail silently for missing/corrupt data for this slice, but code should not crash.
- Do not add workout, session, or custom exercise behavior yet.
