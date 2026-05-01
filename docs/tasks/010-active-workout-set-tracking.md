# TASK-010 - Active Workout Set Tracking

## Type

AFK

## User story

As a user, I can run a workout, track sets, adjust reps and weight, rest between sets, and complete the session.

## What to build

Add the full Active Workout execution experience, excluding final session persistence if TASK-011 is not included in the same branch. This slice should make a workout runnable from beginning to completion using real workout items.

Implement `RestTimer`, `ActiveWorkoutViewModel`, `ActiveWorkoutView`, and any missing shared components such as `StepperView`, `SetTrackerView`, `PrimaryButton`, and `GhostButton`. The screen is presented full-screen from Train and includes top bar, progress, movement name, set tracker, reps and weight cards, previous/skip controls, up-next section, recovery overlay, and completion overlay.

## Acceptance criteria

- [ ] Active Workout starts from a selected saved `Workout`.
- [ ] Active Workout is presented with `fullScreenCover`.
- [ ] Workout items are sorted by `order` before execution.
- [ ] Top bar shows current movement index, total count, elapsed timer, and End button.
- [ ] Progress bar uses scale or equivalent GeometryReader-free approach.
- [ ] Exercise name uses approved 38px heavy typography through `Theme`.
- [ ] Caption shows current set and target reps or max hold.
- [ ] `SetTrackerView` shows completed, current, and pending square states.
- [ ] Reps card defaults to target reps.
- [ ] Reps can be adjusted per set.
- [ ] Weight card defaults to 0 kg.
- [ ] Weight increments/decrements by 2.5 kg and never goes below 0.
- [ ] Mark Set Done records the displayed reps for the current set.
- [ ] Mark Set Done advances to the next set when more sets remain.
- [ ] Mark Set Done advances to the next exercise after the final set of an exercise.
- [ ] Completion state appears after the final set of the final exercise.
- [ ] Rest overlay appears between sets or exercises according to rest rules.
- [ ] Rest overlay auto-dismisses when countdown reaches zero.
- [ ] Skip rest cancels countdown and hides overlay.
- [ ] `RestTimer` uses `Task.sleep(for:)` and not `Timer`, `DispatchQueue`, or `Task.sleep(nanoseconds:)`.
- [ ] Previous exercise control appears only when there is a previous exercise.
- [ ] Skip exercise control appears only when there is a next exercise.
- [ ] Completion overlay shows elapsed time and movement count.
- [ ] `ActiveWorkoutViewModel` tests cover set advancement, exercise advancement, completion, and completed set data.
- [ ] `RestTimer` tests cover start, skip, and countdown behavior.

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
