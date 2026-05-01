# TASK-007 - Manual Session Builder

## Type

AFK

## User story

As a user, I can manually create or edit a workout made of chosen movements.

## What to build

Add the manual workout creation and edit path. This slice should allow a user to go from Train to Session Builder, choose movements from the exercise library, configure sets/reps/rest, select training days, save, and return to Train where the saved workout appears.

Implement `SessionBuilderViewModel`, `SessionBuilderView`, and `ExercisePickerView` if not already present. Wire create and edit navigation from Train using `navigationDestination(for:)`. Support manual mode, movement add/remove, movement steppers, scheduled day chips, estimated duration, and persistence through `WorkoutRepository`.

## Acceptance criteria

- [ ] Train add action can route to Session Builder create mode.
- [ ] Train edit action routes to Session Builder edit mode with existing workout data.
- [ ] Session Builder uses custom `NavBarView` with Back, title, and Save.
- [ ] Create mode title is `New Session`.
- [ ] Edit mode title is `Edit Session`.
- [ ] Session name field is present and persists to `Workout.name`.
- [ ] Set style control includes `Smart pick` and `I choose`.
- [ ] Manual mode is represented by `I choose` and persists as approved model value.
- [ ] Movement section includes Add button.
- [ ] Add opens `ExercisePickerView` as a sheet or equivalent approved presentation.
- [ ] Exercise Picker supports search, muscle filter chips, and picker-mode rows with plus icon.
- [ ] Tapping a movement adds it to the builder and returns to the builder.
- [ ] Movement cards show drag icon, movement name, meta line, remove button, and inline steppers.
- [ ] Sets stepper increments by 1 and respects a sensible minimum.
- [ ] Reps stepper increments by 1 and respects a sensible minimum.
- [ ] Rest stepper increments by 15 seconds and displays seconds.
- [ ] Training days show the seven approved small chips.
- [ ] Estimated duration updates when movements or rest/sets values change.
- [ ] Saving create mode creates a `Workout` and ordered `WorkoutItem` records.
- [ ] Saving edit mode updates the existing workout rather than creating a duplicate.
- [ ] Successful save pops back to Train.
- [ ] Train reloads and displays the saved or updated workout.
- [ ] `SessionBuilderViewModel` tests cover add movement, remove movement, estimated duration, create save, and edit prepopulation.

## Blocked by

- TASK-003 - `docs/tasks/003-searchable-movement-catalog.md`
- TASK-006 - `docs/tasks/006-workout-persistence-and-train-list.md`

## Additional references

- `docs/design.html:L467-L638` - Prototype Session Builder and Movement Picker implementation details.
- `docs/design.html:L830-L853` - Prototype routing into builder from Train and builder movement picker flow.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L296-L373` - Approved Session Builder and Movement Picker layouts and interactions.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L514-L530` - Approved navigation model for Train to Session Builder and Movement Picker.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L126-L145` - Workout and WorkoutItem schema used by manual builder saves.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L180-L204` - Workout repository save boundary.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L252-L283` - Navigation architecture for Train sub-screens.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L286-L317` - ViewModel layer and SwiftData-free view constraints.

## Implementation notes

- Keep all builder state in `SessionBuilderViewModel`.
- Views should not manipulate SwiftData models directly except through ViewModel state and actions.
- Use repository protocols in ViewModels.
- Do not implement smart generation yet; the smart UI can show the approved info card but generation belongs to TASK-008.
- Do not implement active workout start behavior beyond preserving route hooks.
