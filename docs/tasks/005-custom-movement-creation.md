# TASK-005 - Custom Movement Creation

## Type

AFK

## User story

As a user, I can add a custom movement and see it in the movement catalog.

## What to build

Add custom movement creation as a sheet from the Library plus button. This slice should complete a create path through UI, ViewModel, repository, SwiftData persistence, catalog refresh, and visible custom badge.

Implement `CustomExerciseViewModel` and `CustomExerciseForm`. The form collects name, primary muscle, optional secondary muscles, and equipment. It validates required fields, saves a new `Exercise` with `isCustom = true`, dismisses, and refreshes Library state.

## Acceptance criteria

- [x] Library plus button opens `CustomExerciseForm` as a sheet.
- [x] Form uses custom `NavBarView` with Cancel, `New Exercise`, and Save.
- [x] Name input is present and uses approved surface/border styling.
- [x] Primary muscle section uses single-select chips.
- [x] Secondary muscles section uses multi-select chips.
- [x] Equipment section uses multi-select chips.
- [x] Save is disabled while name is blank or primary muscle is not selected.
- [x] Name is trimmed before saving.
- [x] If no equipment is selected, saved equipment defaults to `None`.
- [x] Saved exercise has `isCustom = true`.
- [x] Saved exercise has default `frequencyPreference = normal` unless explicitly changed by model default.
- [x] Save goes through `ExerciseRepository.save`.
- [x] Successful save dismisses the sheet.
- [x] Library refreshes and shows the new custom exercise.
- [x] New custom exercise row shows the `CUSTOM` badge.
- [x] Save errors are surfaced through ViewModel error state.
- [x] `CustomExerciseViewModel` tests cover invalid state, valid state, default equipment, trimmed name, and repository save.

## Blocked by

- TASK-003 - `docs/tasks/003-searchable-movement-catalog.md`

## Additional references

- `docs/design.html:L721-L723` - Prototype Library plus button placement for custom movement entry.
- `docs/design.html:L735-L740` - Prototype Library row and custom badge rendering.
- `docs/design.html:L750-L758` - Prototype custom badge styling in Movement Detail for custom exercises.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L117-L119` - Custom badge styling on exercise rows.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L429-L451` - Library plus button and catalog behavior.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L455-L462` - Custom badge display on Movement Detail.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L26-L77` - File locations for `CustomExerciseViewModel` and `CustomExerciseForm`.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L110-L124` - Exercise model fields populated by custom exercise creation.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L180-L204` - Exercise repository save boundary.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L286-L317` - ViewModel injection and view constraints.

## Implementation notes

- Keep the form as a sheet owned by Library navigation state.
- Views should not construct repository implementations; inject through environment and ViewModel initializer.
- Use the same muscle and equipment vocabulary as seed data and model comments.
- Do not add editing/deleting custom movements unless explicitly scoped later.
