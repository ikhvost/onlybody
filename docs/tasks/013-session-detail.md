# TASK-013 - Session Detail

## Type

AFK

## User story

As a user, I can inspect per-set details from a completed workout.

## What to build

Add the session drill-down screen from Log rows. This slice should make one completed session fully inspectable: date, duration, calories, movement list, total reps, and per-set reps.

Implement `SessionDetailViewModel` and `SessionDetailView`. The ViewModel can be initialized with the selected session or loaded through repository composition depending on the navigation approach chosen earlier, but the view must remain thin and SwiftData-free.

## Acceptance criteria

- [ ] Tapping a Log row opens Session Detail.
- [ ] Detail route uses `navigationDestination(for:)`.
- [ ] Screen uses custom `NavBarView` with Back and session workout name as title.
- [ ] Date displays in approved uppercase weekday/month/day format, for example `FRIDAY, MAY 1`.
- [ ] Duration displays in `MM:SS` and uses amber mono styling.
- [ ] Calories display uses approved mono styling and handles nil values.
- [ ] Session items are sorted by `order`.
- [ ] Each session item shows exercise name.
- [ ] Each session item shows total reps computed from `setReps`.
- [ ] Each completed set is rendered as a mono line such as `SET 1 - 12 REPS` or the approved equivalent label.
- [ ] Divider styling matches the approved design.
- [ ] `Repeat this session` ghost button is present as an MVP affordance.
- [ ] Repeat button does not need to perform an action unless separately scoped.
- [ ] `SessionDetailView` does not import SwiftData, use `@Query`, or access `ModelContext`.
- [ ] `SessionDetailViewModel` tests cover date formatting, duration formatting, sorted items, and total reps.

## Blocked by

- TASK-012 - `docs/tasks/012-training-log.md`

## Additional references

- `docs/design.html:L676-L703` - Prototype Session Detail screen layout and per-set breakdown.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L402-L425` - Approved Session Detail layout, metrics, total reps, and repeat button.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L147-L176` - Session and SessionItem model fields used by detail display.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L252-L283` - Log route navigation to Session Detail.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L286-L317` - ViewModel construction and SwiftData-free view constraints.

## Implementation notes

- Keep the detail read-only for MVP.
- Avoid C-style string formatting in user-facing SwiftUI text where modern formatting APIs can be used.
- If existing code uses snapshot models for detail display, preserve that separation rather than adding view-level SwiftData access.
