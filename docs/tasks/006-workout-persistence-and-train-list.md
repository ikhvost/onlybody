# TASK-006 - Workout Persistence And Train List

## Type

AFK

## User story

As a user, I can see saved workouts on the Train tab.

## What to build

Add workout persistence and replace the Train placeholder with a repository-backed Train root. This slice should establish the workout data model and show saved workouts in the Train tab, even before the builder flow is available.

Create `Workout` and `WorkoutItem` SwiftData models, `WorkoutRepository` protocol, `SwiftDataWorkoutRepository`, `TrainViewModel`, and `TrainView`. The screen should load workouts from the repository and render the approved Train header, day strip, empty state, and workout row structure. Start and edit actions may route to placeholders until later tasks complete.

## Acceptance criteria

- [x] `Workout` is a SwiftData `@Model` in its own file.
- [x] `WorkoutItem` is a SwiftData `@Model` in its own file.
- [x] `Workout.id` uses `@Attribute(.unique)`.
- [x] `Workout` includes name, mode, target muscle groups, scheduled days, created date, and optional items relationship.
- [x] `WorkoutItem` includes id, order, sets, target reps, rest seconds, optional exercise relationship, and optional workout relationship.
- [x] Relationships use optional values and approved delete rules.
- [x] `WorkoutRepository` exposes `allWorkouts`, `save`, and `delete`.
- [x] `SwiftDataWorkoutRepository` accepts `ModelContext` through initializer.
- [x] `allWorkouts()` returns saved workouts in stable order.
- [x] `TrainViewModel` is `@Observable` and `@MainActor`.
- [x] `TrainViewModel` depends on `WorkoutRepository` and `SessionRepository` protocol placeholders only where needed.
- [x] Train screen loads workouts from the repository.
- [x] Train header uses approved date/title/add button layout.
- [x] Day strip renders all seven days.
- [x] Empty state appears when no workouts exist.
- [x] Workout rows show name, scheduled days or `UNSCHEDULED`, movement count, edit button, and start button.
- [x] `TrainView` does not import SwiftData, use `@Query`, or access `ModelContext`.
- [x] In-memory repository tests cover workout save, fetch, and delete.

## Blocked by

- TASK-002 - `docs/tasks/002-seeded-movement-persistence-tracer.md`

## Additional references

- `docs/design.html:L49-L74` - Prototype workout data shape and scheduled workout examples.
- `docs/design.html:L226-L297` - Prototype Train screen header, day strip, today callout, and workout rows.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L163-L201` - Approved Train screen layout, features, and navigation entry points.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L126-L145` - Approved `Workout` and `WorkoutItem` SwiftData model fields.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L167-L176` - Model decisions for workout mode, scheduled days, and Train display.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L180-L204` - Workout repository protocol and implementation boundary.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L286-L317` - Train ViewModel example and view constraints.

## Implementation notes

- This task establishes Train as data-backed, but it does not need to create workouts yet.
- Keep start and edit closures ready for later navigation wiring.
- Use `PersistentIdentifier` or another route-safe identifier if route placeholders need IDs.
- Do not implement Session Builder, Muscle Picker, or Active Workout in this task.
