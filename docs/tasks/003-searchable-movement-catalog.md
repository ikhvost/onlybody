# TASK-003 - Searchable Movement Catalog

## Type

AFK

## User story

As a user, I can browse, search, and filter movements in the Library.

## What to build

Replace the simple Library placeholder with the approved movement catalog experience backed by real `Exercise` data. This slice should make the Library tab feel like a complete feature: header, search, filters, rows, custom badge rendering, loading state, empty state, and ViewModel test coverage.

Add `LibraryViewModel`, `LibraryView`, and shared components needed for the catalog path, including `MonoLabel`, `ChipView`, `ExerciseRow`, and any supporting search field structure. The ViewModel owns loading, search text, selected filter, and computed filtered results. The view renders only state and sends user actions back to the ViewModel or navigation closure.

## Acceptance criteria

- [ ] `LibraryViewModel` is `@Observable` and `@MainActor`.
- [ ] `LibraryViewModel` depends on `ExerciseRepository` protocol, not SwiftData types.
- [ ] `LibraryViewModel.load()` populates `allExercises` from the repository and exposes loading/error state.
- [ ] `filteredExercises` filters by selected muscle and search text.
- [ ] Search uses `localizedStandardContains`.
- [ ] Library header matches the design: mono `MOVEMENT CATALOG`, title `Library`, and amber plus button.
- [ ] Search field uses custom `SearchIcon`.
- [ ] Filter row uses horizontally scrolling small `ChipView`s.
- [ ] Filter values include `All`, `Chest`, `Back`, `Shoulders`, `Arms`, `Core`, `Quads`, `Glutes`, `Hamstrings`, and `Calves`.
- [ ] Movement rows are rendered with reusable `ExerciseRow`.
- [ ] `ExerciseRow` shows exercise name, primary muscle, equipment, trailing chevron in Library mode, and bottom divider.
- [ ] Custom exercises render the approved `CUSTOM` badge.
- [ ] Empty state appears when no exercises match search/filter.
- [ ] Loading and repository error states are visible or alertable through ViewModel state.
- [ ] `LibraryView` does not import SwiftData, use `@Query`, or access `ModelContext`.
- [ ] `LibraryViewModel` tests cover loading, search filtering, muscle filtering, combined filtering, and error state.

## Blocked by

- TASK-002 - `docs/tasks/002-seeded-movement-persistence-tracer.md`

## Additional references

- `docs/design.html:L603-L638` - Prototype Movement Picker search, filter, and row behavior shared with Library interactions.
- `docs/design.html:L705-L748` - Prototype Library screen header, search field, filters, rows, custom badge, and navigation.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L117-L119` - Approved reusable Exercise Row component details.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L351-L373` - Movement Picker search/filter/row interaction reference.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L429-L451` - Approved Library screen layout and behavior.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L12-L23` - View/ViewModel/Repository architecture constraints.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L180-L204` - Exercise repository interface and SwiftData implementation expectations.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L286-L317` - ViewModel layer requirements and SwiftData-free views.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L455-L463` - ViewModel and repository testing strategy.

## Implementation notes

- Reusable shared components should be generic and not own ViewModels.
- Use the approved fixed typography scale through `Theme`.
- Use buttons for row and chip interactions; do not use `onTapGesture`.
- Hide scroll indicators where the design expects hidden indicators.
- Do not add Movement Detail or Custom Exercise behavior in this task beyond navigation closures or placeholders.
