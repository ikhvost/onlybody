# TASK-010 - Active Workout Set Tracking

## Type

AFK

## User story

As a user, I can run a workout, track sets, adjust reps and weight, rest between sets, and complete the session.

## What to build

Add the full Active Workout execution experience, excluding final session persistence if TASK-011 is not included in the same branch. This slice should make a workout runnable from beginning to completion using real workout items.

Implement `RestTimer`, `ActiveWorkoutViewModel`, `ActiveWorkoutView`, and any missing shared components such as `StepperView`, `SetTrackerView`, `PrimaryButton`, and `GhostButton`. The screen is presented full-screen from Train and includes top bar, progress, movement name, set tracker, reps and weight cards, previous/skip controls, up-next section, recovery overlay, and completion overlay.

## Acceptance criteria

- [x] Active Workout starts from a selected saved `Workout`.
- [x] Active Workout is presented with `fullScreenCover`.
- [x] Workout items are sorted by `order` before execution.
- [x] Top bar shows current movement index, total count, elapsed timer, and End button.
- [x] Progress bar uses scale or equivalent GeometryReader-free approach.
- [x] Exercise name uses approved 38px heavy typography through `Theme`.
- [x] Caption shows current set and target reps or max hold.
- [x] `SetTrackerView` shows completed, current, and pending square states.
- [x] Reps card defaults to target reps.
- [x] Reps can be adjusted per set.
- [x] Weight card defaults to 0 kg.
- [x] Weight increments/decrements by 2.5 kg and never goes below 0.
- [x] Mark Set Done records the displayed reps for the current set.
- [x] Mark Set Done advances to the next set when more sets remain.
- [x] Mark Set Done advances to the next exercise after the final set of an exercise.
- [x] Completion state appears after the final set of the final exercise.
- [x] Rest overlay appears between sets or exercises according to rest rules.
- [x] Rest overlay auto-dismisses when countdown reaches zero.
- [x] Skip rest cancels countdown and hides overlay.
- [x] `RestTimer` uses `Task.sleep(for:)` and not `Timer`, `DispatchQueue`, or `Task.sleep(nanoseconds:)`.
- [x] Previous exercise control appears only when there is a previous exercise.
- [x] Skip exercise control appears only when there is a next exercise.
- [x] Completion overlay shows elapsed time and movement count.
- [x] `ActiveWorkoutViewModel` tests cover set advancement, exercise advancement, completion, and completed set data.
- [x] `RestTimer` tests cover start, skip, and countdown behavior.

## Blocked by

- TASK-009 - `docs/tasks/009-scheduled-train-home.md`

## Additional references

- `docs/design.html:L143-L197` - Prototype primary, ghost, back, chip, and stepper primitives used by Active Workout.
- `docs/design.html:L299-L436` - Prototype Active Session screen, rest overlay, and completion screen behavior.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L83-L119` - Approved Mono, button, chip, stepper, set tracker, and exercise row components.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L204-L263` - Approved Active Session, Recovery Overlay, and Session Complete layouts.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L534-L544` - Approved motion timing for recovery overlay, set tracker, progress bar, and buttons.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L252-L283` - Active Workout full-screen cover navigation rule.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L286-L317` - ViewModel layer requirements.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L399-L432` - RestTimer implementation requirements and forbidden legacy timer APIs.

## Implementation notes

- Keep timing lifecycle inside ViewModel/service layer, not in the view.
- Avoid accidental back navigation during active workout by relying on full-screen cover.
- Persisting completed sessions is TASK-011; this task may provide hooks or temporary no-op save behavior.
- Keep recovery overlay and completion overlay visually faithful to `docs/design.html`.
