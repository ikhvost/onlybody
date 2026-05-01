# TASK-008 - Smart Muscle Session Builder

## Type

AFK

## User story

As a user, I can select target muscles and build a smart workout.

## What to build

Add the target-muscle flow and smart workout generation. This slice should connect Muscle Picker, Session Builder smart mode, exercise preferences from Movement Detail, and saved workouts.

Implement `MusclePickerViewModel`, `MusclePickerView`, and `SmartWorkoutGenerator`. The user starts from Train plus, selects one or more muscle groups, lands in Session Builder with target chips visible, and can save a smart workout that generates movements from the exercise repository.

## Acceptance criteria

- [ ] Train plus opens Muscle Picker before Session Builder.
- [ ] Muscle Picker uses custom `NavBarView` with Back and `New Session`.
- [ ] Muscle Picker shows the approved heading and mono label.
- [ ] Muscle Picker includes all 12 approved muscle chips: Chest, Back, Shoulders, Arms, Core, Quads, Glutes, Hamstrings, Calves, Full Body, Upper, and Lower.
- [ ] Muscle chips toggle selection.
- [ ] Selection summary joins selected muscles with ` + `.
- [ ] Build button is disabled until at least one muscle is selected.
- [ ] Build routes to Session Builder with selected targets.
- [ ] Skip routes to Session Builder with no targets.
- [ ] Session Builder displays selected targets as read-only amber dim chips.
- [ ] Smart mode shows the approved auto-selected movements info card.
- [ ] Saving in smart mode generates workout items from available exercises.
- [ ] `SmartWorkoutGenerator` excludes exercises where `frequencyPreference == never`.
- [ ] `SmartWorkoutGenerator` matches exercises by primary muscle or secondary muscles.
- [ ] `SmartWorkoutGenerator` sorts preference order as `more`, then `normal`, then `less`.
- [ ] `SmartWorkoutGenerator` respects duration budget except for the first generated item.
- [ ] Fallback behavior uses equipment-free exercises when too few matches exist.
- [ ] Generated workout persists target muscle groups to `Workout.targetMuscleGroups`.
- [ ] Generated workout appears on Train after save.
- [ ] Service tests cover exclusion, preference ordering, duration budget, fallback, and muscle filtering.

## Blocked by

- TASK-004 - `docs/tasks/004-movement-detail-preferences.md`
- TASK-007 - `docs/tasks/007-manual-session-builder.md`

## Additional references

- `docs/design.html:L103-L110` - Prototype muscle group vocabulary.
- `docs/design.html:L438-L465` - Prototype Muscle Picker screen behavior.
- `docs/design.html:L497-L531` - Prototype Session Builder target chips and smart-pick info card.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L267-L292` - Approved Muscle Picker layout and selection behavior.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L296-L347` - Approved Session Builder smart mode, target chips, and save affordance.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L167-L176` - Data model decisions for target muscles and frequency preferences.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L320-L373` - SmartWorkoutGenerator configuration, filtering, ordering, time budget, and purity requirements.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L444-L451` - Error handling for empty smart-pick pools and fallback behavior.

## Implementation notes

- `SmartWorkoutGenerator` should be pure logic with no SwiftUI imports.
- Prefer returning value-type generated items and mapping to SwiftData models in the ViewModel.
- Avoid force unwraps when choosing random rest values.
- Keep the generator deterministic enough for tests where possible by isolating or controlling randomness if needed.
- Do not implement active workout execution in this task.
