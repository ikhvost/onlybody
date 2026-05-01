# TASK-014 - Streak Insights

## Type

AFK

## User story

As a user, I can see my training consistency from completed sessions.

## What to build

Add streak insights from saved session history. This slice should compute current streak, longest streak, total sessions, and a 20-week activity heatmap from actual `Session` data.

Implement `StreakCalculator`, `StreakViewModel`, and `StreakView`. Wire a Train header route to the Streak screen. The service must be testable independently and the view must render the approved stat cards and heatmap.

## Acceptance criteria

- [ ] Train provides an approved route to Streak screen.
- [ ] Streak route uses `navigationDestination(for:)`.
- [ ] `StreakCalculator` is pure logic and has no SwiftUI imports.
- [ ] `StreakCalculator.calculate` accepts sessions and optional today date.
- [ ] Empty sessions produce current `0`, longest `0`, total `0`.
- [ ] One session today produces current `1`, longest `1`, total `1`.
- [ ] One session yesterday produces current `0`, longest `1`, total `1`.
- [ ] Consecutive sessions through today produce matching current and longest values.
- [ ] Gaps break the current streak.
- [ ] Past longest run is preserved even when current streak is shorter.
- [ ] Duplicate sessions on the same day do not inflate current or longest streak.
- [ ] Total uses raw session count, not deduplicated day count.
- [ ] `StreakViewModel` depends on `SessionRepository` protocol.
- [ ] `StreakViewModel` builds a 20 week by 7 day heatmap.
- [ ] Heatmap cells reflect actual session days using start-of-day comparison.
- [ ] Streak screen renders Current, Longest, and Total stat cards.
- [ ] Current value uses dim text color; Longest and Total use accent.
- [ ] Heatmap uses 7 rows and 20 columns with approved cell styling.
- [ ] Service tests cover empty, today, yesterday, consecutive, gap, past longest, and duplicate-day cases.

## Blocked by

- TASK-011 - `docs/tasks/011-completed-session-save.md`

## Additional references

- `docs/design.html:L797-L828` - Prototype Streak screen stat cards and heatmap layout.
- `docs/design.html:L841-L846` - Prototype route handling for Streak screen.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L484-L510` - Approved Streak screen visual layout, stat colors, and heatmap dimensions.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L514-L530` - Approved navigation model and sub-screen behavior.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L252-L283` - Streak route from Train and custom navigation architecture.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L286-L317` - ViewModel layer requirements.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L377-L395` - StreakCalculator service shape and no Streak model decision.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L455-L463` - Service and ViewModel testing strategy.

## Implementation notes

- No Streak SwiftData model should be introduced.
- Streak stats should always be derived from actual sessions.
- Keep date math calendar-based, not raw seconds-based.
- The design copy `Manage streak in Settings` can remain informational for MVP.
