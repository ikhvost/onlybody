# Documentation And Rules

## Purpose

This file defines the current documentation policy for OnlyBody.

Use it to avoid two common failures:

1. treating old MVP planning artifacts as active implementation requirements
2. making structural changes without understanding which rules are still active

This document is intentionally written for agents and engineers who need a reliable current context.

## Status Change

The repository is no longer in the original MVP-planning phase.

What changed:

- The old design, technical plan, and task files were useful to build the MVP.
- They are no longer the default source of truth for day-to-day work.
- Many of their assumptions are now stale, incomplete, or too rigid for the next phase of the app.
- The codebase must now be guided by current structure, current rules, and incremental architecture improvement.

## Active Documents

These are the active documents agents should rely on first:

1. `AGENTS.md`
2. `DOCUMENTATION_AND_RULES.md`
3. `APPLICATION_CHANGE_CONTEXT.md`
4. `README.md`

Use these four as the current operating context.

## Archived Documents

Historical MVP planning artifacts now live in:

- `docs/archive/mvp/design.html`
- `docs/archive/mvp/plans/`
- `docs/archive/mvp/tasks/`

They are archive material, not mandatory prereads.

## How To Use Archived Docs

Archived docs are reference material only.

Read them only when one of these is true:

1. the task explicitly asks for the original MVP design or behavior
2. you need to understand why an older implementation decision exists
3. you are reviewing drift against the original MVP
4. current code is ambiguous and historical intent matters

Do not read archived docs by default before every UI task.
Do not block implementation waiting on archived docs unless the task requires historical fidelity.

## New Source-Of-Truth Policy

There is no single giant document that should control all future work.

Instead, use this priority order:

1. the user request in the current conversation
2. `AGENTS.md`
3. `DOCUMENTATION_AND_RULES.md`
4. `APPLICATION_CHANGE_CONTEXT.md`
5. current code behavior and current file layout
6. archived MVP docs, only if needed

This is a deliberate change from the old model where the design HTML and large planning documents were treated as mandatory source material.

## What Is No Longer Required

The following old habits are explicitly deprecated:

- mandatory reading of `design.html` before any UI change
- mandatory reading of the full MVP tech plan before architecture work
- treating old task files as active implementation tickets
- assuming the documented target structure exactly matches the checked-in code
- assuming every screen already follows the ideal View -> ViewModel -> Repository shape

## What Still Remains Active

These engineering rules still matter:

- SwiftUI + SwiftData only
- on-device storage only
- no third-party dependencies
- `@Observable` + `@MainActor` view models
- repository protocol boundary
- no SwiftData usage inside views
- no `TabView` for app tabs
- no `NavigationLink` for app flow
- prefer small, targeted changes
- keep visual tokens centralized in `Theme.swift`

The old documentation contained both good evergreen rules and stale implementation planning. The goal now is to keep the evergreen rules and stop dragging the full historical planning burden into every task.

## Documentation Roles

### `AGENTS.md`

Repo-level operating rules.

It should stay concise, stable, and practical.
It should not contain frozen MVP project trees that become stale quickly.

### `DOCUMENTATION_AND_RULES.md`

Explains doc policy, archive policy, and how to decide which instructions are active.

### `APPLICATION_CHANGE_CONTEXT.md`

Explains current app structure, structural pain points, the target direction, and the migration path.

### `README.md`

High-level project entrypoint for humans and agents.
It should describe the current app and point to the active documents above.

### `docs/archive/mvp/`

Historical context only.
Useful, but not authoritative by default.

## Rules For Future Documentation Changes

When updating docs going forward:

1. prefer short active docs over giant speculative plans
2. document the current system honestly, including known gaps
3. separate historical reference from current guidance
4. avoid declaring an idealized architecture as if it already exists
5. update agent entrypoints when documentation policy changes
6. archive obsolete docs instead of silently leaving them in active paths

## Rules For Agents

If you are another agent working in this repo, follow these rules:

1. start with `AGENTS.md`, this file, and `APPLICATION_CHANGE_CONTEXT.md`
2. inspect current code before repeating assumptions from archived plans
3. do not cite archived MVP docs as mandatory unless the task explicitly calls for them
4. when a current code pattern and an archived spec differ, prefer the current active context unless asked for legacy parity
5. if a task is architecture-related, optimize for incremental migration, not a large rewrite
6. if you touch documentation, keep active docs small and current

## Immediate Practical Consequences

From this point forward:

- UI tasks should use current code and `Theme.swift` as the primary implementation baseline
- architecture tasks should use `APPLICATION_CHANGE_CONTEXT.md`
- historical design verification is opt-in, not mandatory
- archived task files should not be reopened as if they are an active backlog

## Cleanup Already Applied

This repo cleanup made these changes:

- old MVP docs were moved into `docs/archive/mvp/`
- active agent guidance now points to the new root-level docs
- the repo is now prepared for future agents to work from current context instead of old MVP planning context

## What To Do Next

When future work begins, use this sequence:

1. read `AGENTS.md`
2. read `DOCUMENTATION_AND_RULES.md`
3. read `APPLICATION_CHANGE_CONTEXT.md`
4. inspect relevant code
5. consult archived MVP docs only if the task actually needs historical reference

That is the intended operating model for the repo now.
