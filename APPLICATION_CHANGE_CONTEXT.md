# Application Change Context

## Purpose

This document gives future agents a detailed, current, and practical understanding of the OnlyBody application structure.

It is not a nostalgic MVP design document.
It is not an idealized architecture manifesto.
It is a working guide for making the next round of improvements without re-importing outdated assumptions.

## Executive Summary

The app is in a mixed state:

- the product MVP is implemented
- the documentation used to build that MVP is now archived
- the codebase already has solid foundations
- the structure is still partly layer-first and partly feature-first
- the next improvements should focus on discoverability, ownership, and incremental architecture cleanup

The most important structural fact is this:

The app is not badly broken architecturally, but its organization no longer matches the story told by the old docs.

## Core Technical Constraints

These remain active and should be preserved unless the user explicitly asks to change them:

- Platform: iOS 26.0+
- Language: Swift 6.2
- Strict concurrency
- Frameworks: SwiftUI + SwiftData
- Storage: on-device only
- Dependencies: no third-party libraries

## Current Real Architecture

### High-level interaction model

The intended runtime flow is still:

```text
View -> ViewModel (@Observable @MainActor) -> Repository protocol -> SwiftData repository
```

This is still the correct mental model.

### Important nuance

The repository boundary exists, but the app is not yet fully domain-decoupled from SwiftData models.

That means:

- repositories are abstracted behind protocols
- views do not import SwiftData
- view models depend on repository protocols
- but many view models and services still use `Exercise`, `Workout`, `Session`, and related SwiftData model types directly

This is acceptable for the current stage.
Do not pretend the app already has a separate domain model layer.

## Current File-System Shape

Actual application code currently lives under:

```text
onlybody/onlybody/
├── App/
├── Data/
├── Models/
├── Resources/
├── Services/
├── Shared/
├── ViewModels/
└── Views/
```

### What this means in practice

- Views are grouped by feature under `Views/Train`, `Views/Log`, and `Views/Library`
- View models are still flat under `ViewModels/`
- Repositories and seed logic are grouped under `Data/`
- Shared design and reusable UI live under `Shared/`
- Some code in `Shared/` is not truly shared and should eventually move closer to feature ownership

## Current App Composition

### `App/BodyweightApp.swift`

Current role:

- creates the `ModelContainer`
- creates repository implementations
- seeds data
- launches `AppTabView`

This is already acting as part of the composition root.

### `App/AppTabView.swift`

Current role:

- holds selected tab state
- owns per-tab `NavigationPath`
- constructs root view models
- registers navigation destinations
- presents `ActiveWorkoutView` as full-screen cover
- handles some refresh behavior when navigation unwinds

This file is the main orchestration point in the app.

That is the biggest current structural pressure point.

### Why it matters

`AppTabView` is doing more than a tab shell should do.

It currently behaves as:

- tab shell
- navigation owner
- per-feature destination builder
- partial dependency container
- view-model factory

This is manageable for MVP size, but it will become harder to maintain as features evolve.

## Current Feature Boundaries

### Train feature

Current view files:

- `Views/Train/TrainView.swift`
- `Views/Train/MusclePickerView.swift`
- `Views/Train/SessionBuilderView.swift`
- `Views/Train/ActiveWorkoutView.swift`
- `Views/Train/StreakView.swift`
- `Views/Train/TrainRoute.swift`

Current view models:

- `ViewModels/TrainViewModel.swift`
- `ViewModels/MusclePickerViewModel.swift`
- `ViewModels/SessionBuilderViewModel.swift`
- `ViewModels/ActiveWorkoutViewModel.swift`
- `ViewModels/StreakViewModel.swift`

Notes:

- Train already behaves like a real feature module from a runtime perspective
- it is only split physically across multiple top-level folders
- `TrainRoute.swift` is already a sign that feature-local routing exists here

### Log feature

Current view files:

- `Views/Log/LogView.swift`
- `Views/Log/SessionDetailView.swift`

Current view models:

- `ViewModels/LogViewModel.swift`

Notes:

- `SessionDetailView` currently takes `Session` directly
- there is no `SessionDetailViewModel`
- this is a valid simplification for now, but it means the architecture is not uniform across screens

### Library feature

Current view files:

- `Views/Library/LibraryView.swift`
- `Views/Library/MovementDetailView.swift`
- `Views/Library/CustomExerciseForm.swift`
- `Views/Library/LibraryExerciseRow.swift`

Current view models:

- `ViewModels/LibraryViewModel.swift`
- `ViewModels/MovementDetailViewModel.swift`
- `ViewModels/CustomExerciseViewModel.swift`

Notes:

- `LibraryExerciseRow.swift` already belongs naturally to the Library feature
- `LibraryView` also owns presentation state for the custom exercise sheet
- the feature boundary exists logically, but not yet in the folder structure

## Current Shared and Core Code

### `Data/`

Contains:

- repository protocols
- SwiftData repository implementations
- seed data and seed manager

This is a reasonable structure and does not need a large rewrite right now.

### `Models/`

Contains SwiftData model types:

- `Exercise`
- `Workout`
- `WorkoutItem`
- `Session`
- `SessionItem`

These are still the app's effective domain objects in many places.

### `Services/`

Contains:

- `SmartWorkoutGenerator`
- `StreakCalculator`
- `RestTimer`

This area is already conceptually clean.

### `Shared/`

Currently contains:

- `Theme/`
- `Icons/`
- `Components/`
- `Domain/`
- `Preview/`

This folder needs tightening.

Some of it is truly shared.
Some of it is acting as overflow storage.

## Current Structural Problems

These are the important ones. Future agents should understand them before proposing changes.

### 1. Feature code is split across parallel global folders

Example:

- `Views/Train/TrainView.swift`
- `ViewModels/TrainViewModel.swift`

This slows navigation of the codebase and weakens feature ownership.

### 2. `AppTabView` is overloaded

This is the largest structural hotspot.

Future work should reduce its responsibilities instead of growing it further.

### 3. Navigation patterns are inconsistent

Examples:

- Train uses typed routing through `TrainRoute`
- Log and Library push raw `UUID` values

This is not a bug, but it is a maintainability inconsistency.

### 4. `Shared` contains non-universal code

Example candidates:

- `Shared/Components/ExercisePickerView.swift`
- `Shared/Preview/`
- parts of `Shared/Domain/`

This makes `Shared` drift toward a dumping ground.

### 5. Some screens are view-driven instead of consistently view-model-driven

Example:

- `Views/Log/SessionDetailView.swift`

This is not urgent to change, but it should be described honestly.

### 6. Some files still mix ownership or type responsibilities

Example:

- `ViewModels/SessionBuilderViewModel.swift` also defines `MovementConfig`

That is a minor but useful cleanup target.

## Target Direction

The recommended next structure is a simple feature-first organization adapted to this app, not copied blindly from generic articles.

## Recommended Target Structure

```text
onlybody/onlybody/
├── App/
│   ├── BodyweightApp.swift
│   ├── AppTab.swift
│   ├── AppTabView.swift
│   └── AppDependencies.swift
├── Features/
│   ├── Train/
│   │   ├── TrainFlowView.swift
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   ├── Routing/
│   │   └── Components/
│   ├── Log/
│   │   ├── LogFlowView.swift
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Routing/
│   └── Library/
│       ├── LibraryFlowView.swift
│       ├── Views/
│       ├── ViewModels/
│       ├── Routing/
│       └── Components/
├── Core/
│   ├── Repositories/
│   ├── Services/
│   ├── Domain/
│   └── Seed/
├── Models/
├── Shared/
│   ├── Theme/
│   ├── Icons/
│   └── Components/
├── PreviewSupport/
├── Resources/
└── Tests/
```

## Why This Structure Fits OnlyBody

This structure is the right next step because it:

- preserves the current app shape instead of replacing it with a foreign pattern
- aligns physical folders with real feature ownership
- keeps a thin app shell as the long-term direction
- avoids an expensive domain rewrite
- makes future onboarding and code search faster
- reduces the chance that `Shared` becomes a junk drawer

## What Should Not Be Copied From Generic Architecture Articles

Future agents should not blindly introduce patterns that conflict with this repo.

Do not copy in these article-style defaults unless the user explicitly asks for them:

- `ObservableObject`
- `@Published`
- `@EnvironmentObject`
- app-wide `TabView`
- auth-centric root-flow patterns that do not exist in this app
- large singleton-heavy service containers by default

The article is useful for structure, ownership, and composition ideas.
It is not a direct code template for OnlyBody.

## Recommended Composition Model

### App shell

Long-term goal:

- `BodyweightApp` creates app dependencies once
- `AppTabView` selects tabs and renders bottom navigation
- feature flow views own feature-local navigation and destination mapping

### Dependency construction

Recommended next abstraction:

- add `AppDependencies.swift`

That type should centralize:

- repository construction
- simple shared service construction if needed
- view-model factory helpers when useful

This should remain lightweight.
It does not need to become a magical service locator.

### Feature flow views

Recommended next step:

- `TrainFlowView`
- `LogFlowView`
- `LibraryFlowView`

Each flow view should own:

- its `NavigationStack`
- its route types
- its destination registration
- creation of its root and destination view models

That change will remove orchestration pressure from `AppTabView` without changing app behavior dramatically.

## Migration Strategy

The migration should be incremental.
Do not do a sweeping rewrite unless the user explicitly asks for it.

### Phase 1. Documentation reset

Done in principle by this cleanup:

- old MVP docs archived
- new active docs created
- repo guidance repointed to current context

### Phase 2. Introduce explicit app dependencies

Recommended changes:

- add `AppDependencies.swift`
- move repository creation out of ad hoc constructor spreading
- keep behavior identical

Goal:

- clearer composition root
- easier future testability and feature ownership

### Phase 3. Introduce feature flow views

Recommended changes:

- keep `AppTabView` as tab shell
- move Train navigation and destination building into `TrainFlowView`
- do the same later for Log and Library

Goal:

- reduce `AppTabView` complexity
- make navigation logic easier to reason about per feature

### Phase 4. Co-locate feature files

Recommended moves:

- move flat view models into `Features/Train/ViewModels`, `Features/Log/ViewModels`, `Features/Library/ViewModels`
- move `TrainRoute.swift` into `Features/Train/Routing/`
- move `LibraryExerciseRow.swift` into Library feature space
- move feature-specific components out of `Shared`

Goal:

- align folder layout with ownership

### Phase 5. Clean up `Shared`

Keep only truly shared code in `Shared`:

- visual tokens
- icons
- universally reusable components

Move out:

- preview-only support into `PreviewSupport/`
- feature-specific helper views into the owning feature
- app-wide enums/constants into `Core/Domain/` if they are not UI-shared concepts

### Phase 6. Consistency cleanup

Examples:

- extract `MovementConfig` into its own file
- decide whether `SessionDetailView` now needs a view model
- normalize route types where raw `UUID` navigation becomes limiting

### Phase 7. Optional deeper architecture work

Only do this if the user explicitly wants it:

- separate domain models from SwiftData models
- introduce mapping layers
- push stronger domain boundaries into services and features

This is a more expensive step and should not be treated as automatic cleanup.

## Practical Rules For Future Agents

If you are making code changes after this cleanup, use these rules:

1. prefer small structural moves over broad rewrites
2. preserve working behavior while improving ownership boundaries
3. do not increase the responsibilities of `AppTabView`
4. do not add new feature-specific code to `Shared` unless it is genuinely reusable
5. when adding a new screen, think in terms of feature ownership first
6. when improving navigation, move it toward feature flow views
7. when writing docs, describe the current truth, not an aspirational one

## When To Consult The Archive

Use `docs/archive/mvp/` only when you need:

- original visual parity
- historical MVP product decisions
- context for why a specific screen or rule exists

Do not use the archive as the default implementation playbook.

## Short Version For Agent Handoffs

If another agent needs a compressed briefing, use this:

OnlyBody has a finished MVP and archived MVP planning docs. Active guidance now lives in `AGENTS.md`, `DOCUMENTATION_AND_RULES.md`, and `APPLICATION_CHANGE_CONTEXT.md`. The current codebase is mixed layer-first and feature-first: views are feature-grouped, view models are flat, and `AppTabView` is overloaded as tab shell plus navigation and view-model factory. The next architecture direction is incremental feature-first organization with a thin app shell, explicit app dependencies, feature flow views, and a smaller `Shared` folder. Do not require archived design or tech docs unless the task explicitly needs historical parity.
