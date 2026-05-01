# TASK-009 - Scheduled Train Home

## Type

AFK

## User story

As a user, I can understand today's training plan and start or edit saved workouts from Train.

## What to build

Complete the Train home experience around schedules and navigation. This slice should make Train behave like the primary command center: today callout, day strip dots, row highlighting, edit routing, start routing, and bottom navigation visibility.

Use existing workouts from the repository. Wire custom navigation routes for Train sub-screens and full-screen active workout presentation with a selected workout identifier. Active Workout may still be a placeholder if TASK-010 has not been merged, but the presentation mechanism must be correct.

## Acceptance criteria

- [ ] Current date label uses approved format such as `FRI, MAY 1`.
- [ ] Train title uses `OnlyBody` with approved typography.
- [ ] Header plus button routes to Muscle Picker.
- [ ] Tapping the title or approved affordance routes to Streak screen placeholder or real screen if available.
- [ ] Day strip renders Sun through Sat.
- [ ] Today is underlined with amber.
- [ ] Day dots reflect whether any saved workout is scheduled for that day.
- [ ] Today's dot is amber when a workout is scheduled today.
- [ ] Non-today scheduled dots use dim border styling.
- [ ] Today callout shows `Today` and scheduled workout names when present.
- [ ] Rest day callout appears when no workouts are scheduled today.
- [ ] Workout rows scheduled today have amber left border.
- [ ] Workout rows not scheduled today have transparent left border.
- [ ] Edit button routes to Session Builder edit mode.
- [ ] Start button sets selected workout for full-screen active workout presentation.
- [ ] Active workout presentation uses `fullScreenCover`.
- [ ] Bottom navigation hides when any tab has a pushed sub-screen.
- [ ] Bottom navigation reappears after popping back to root.
- [ ] App still does not use `TabView`, `Tab`, `tabItem`, or `NavigationLink`.

## Blocked by

- TASK-007 - `docs/tasks/007-manual-session-builder.md`

## Additional references

- `docs/design.html:L199-L224` - Prototype bottom navigation active/inactive states.
- `docs/design.html:L226-L297` - Prototype Train scheduling, row highlighting, edit, and start interactions.
- `docs/design.html:L830-L865` - Prototype app routing and bottom nav hiding on sub-screens.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L144-L157` - Approved bottom navigation behavior and hidden state.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L163-L201` - Approved Train screen schedule, callout, and navigation behavior.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L514-L530` - Approved navigation model and sub-screen bottom-nav hiding.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L252-L283` - Custom tab navigation, navigation stacks, full-screen cover, and no NavigationLink rule.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L286-L317` - ViewModel lifecycle and SwiftData-free view constraints.

## Implementation notes

- Be careful with route ownership: each tab should own its own navigation path.
- Prefer route enums with stable identifiers over passing SwiftData model instances through navigation.
- Avoid `UIScreen.main.bounds` and `GeometryReader`.
- Do not implement Active Workout internals here; focus on Train scheduling and routing.
