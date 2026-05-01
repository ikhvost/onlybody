# TASK-004 - Movement Detail Preferences

## Type

AFK

## User story

As a user, I can inspect a movement and control whether it appears more often, less often, or never in smart sessions.

## What to build

Add the Movement Detail route from Library rows. The detail screen should display exercise metadata and persist frequency preference changes immediately through the exercise repository.

Implement `MovementDetailViewModel` and `MovementDetailView`. Navigation should use route values and `navigationDestination(for:)`. The screen should follow the approved layout for title, custom badge, primary/secondary muscle sections, diagram placeholder, equipment row, and three-option frequency control.

## Acceptance criteria

- [ ] Tapping a Library row pushes Movement Detail with `navigationDestination(for:)`.
- [ ] No `NavigationLink` is introduced.
- [ ] Movement Detail has custom `NavBarView` with Back button and title `Movement`.
- [ ] Screen title shows the exercise name in approved typography.
- [ ] Custom exercises show the approved `CUSTOM` badge.
- [ ] Primary muscle section shows amber square and primary muscle name.
- [ ] Secondary section shows dim square and secondary muscle list joined by comma.
- [ ] Muscle diagram placeholder renders with approved surface, border, height, and mono label.
- [ ] Equipment row shows label and equipment value in mono text.
- [ ] Include-in-sessions control shows `More often`, `Less often`, and `Exclude`.
- [ ] Frequency values map to `more`, `less`, and `never`.
- [ ] Active frequency option uses amber active chip styling.
- [ ] Tapping a frequency option updates `exercise.frequencyPreference`.
- [ ] Updated preference is saved immediately through `ExerciseRepository.save`.
- [ ] Preference remains changed after navigating away and returning.
- [ ] `MovementDetailViewModel` depends only on `ExerciseRepository`.
- [ ] Repository save errors are handled without crashing.
- [ ] No SF Symbols, hardcoded colors, hardcoded font sizes, or hardcoded spacing values are introduced in the view.

## Blocked by

- TASK-003 - `docs/tasks/003-searchable-movement-catalog.md`

## Additional references

- `docs/design.html:L750-L795` - Prototype Movement Detail screen and frequency toggle behavior.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L455-L480` - Approved Movement Detail visual layout and active frequency state.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L110-L124` - Exercise model fields used by Movement Detail.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L167-L176` - Data model decisions for muscles, frequency preference, and diagram placeholder.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L180-L204` - Exercise repository save behavior and protocol boundary.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L286-L317` - ViewModel injection and SwiftData-free view constraints.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L320-L373` - Smart workout dependency on frequency preferences.

## Implementation notes

- This slice intentionally changes behavior that affects smart workout generation later.
- If route lookup by persistent identifier is needed, keep SwiftData lookups inside repositories or app composition, not inside views.
- Keep the diagram as a placeholder; real muscle diagrams are out of scope for MVP.
- Do not implement custom exercise creation in this task.
