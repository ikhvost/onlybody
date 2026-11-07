# Smart Selection — native implementation

6 November 2026. Shared implementation for OnlyBody and OnlyWeights.

## Current scope and approvals

The user's latest instructions supersede section 2 of `SMART-SELECTION.md`: **do not change the exercise catalogs**. OnlyBody retains 99 exercises; OnlyWeights retains 105. Seed stores, canonical keys, exercise translations, media records and existing persistence entities remain unchanged. There is no exercise cleanup or removal from saved workouts.

Selection profiles live separately in `Domain/Services/SmartExerciseProfiles.swift`. They describe the 194 repetition-based movements used by Smart v1. The other ten exercises remain available in the library and manual workouts. Missing profiles are excluded from automatic selection, not deleted from the catalog.

The user explicitly approved two additive SwiftData entities after being informed of the old-store opening risk and the copy-based migration checks. `SmartWorkoutSettingsRecord` is saved in the workout aggregate's transaction; `SmartDailyVariantRecord` stores a detached plan keyed by workout, local civil date and settings revision. Existing model identities and stored properties are unchanged. The implementation never resets a store on migration failure.

## Native behavior

- Creation: muscles → duration/level/name/schedule → optional equipment and load exclusions → daily preview → save/start.
- Smart cards use the same Today/Other schedule grouping as manual workouts, with Start and Edit actions.
- OnlyBody requires explicit equipment availability. OnlyWeights defaults to a standard gym and permits an explicit equipment list.
- Selecting a body area does not infer exclusions. The user chooses specific loads; no clinical region-to-exercise mapping is implemented.
- Automatic selection uses primary muscles, movement coverage, level, equipment, excluded loads and exercise families. Main exercises precede accessories. Prescriptions are explicit, with time for both sides where needed, preparation, rest and transitions.
- Incomplete coverage or a replacement exceeding the time budget blocks saving/starting that preview.
- A saved workout's first preview on a new local day is persisted. Reopening the same day reuses that snapshot. Main anchors survive daily accessory variation.
- A one-session replacement updates the daily plan, not future main anchors. Permanent exclusion is a separate confirmed action. Conflicting alternatives require explicit confirmation identifying the loads involved.
- Active sessions receive the reviewed detached snapshot, use prescribed repetitions and start with zero weight. They do not regenerate after midnight. Active replacements affect only that session; explicit future exclusions update settings independently.
- Existing legacy Smart templates are read without automatic conversion or rewriting. Saving the reviewed Smart draft opts that template into the new settings. Existing manual workflows remain on their existing builder.

## Verification

`SmartSchemaUpgradeTests` copies each product's original seed, opens it with the original five-entity schema, adds a real workout and weighted history, then opens it with the additive schema. It checks all catalog snapshots, workout parameters and schedule, history repetitions and weights, new settings/daily round trips, atomic rollback on a failed aggregate write, and another independent reopen. The bundled seed bytes are compared before and after.

Additional Swift Testing suites cover strict filtering, primary targets, time budgets, family uniqueness, deterministic ordering, main anchors, local-day/revision cache keys, explicit replacements, preview persistence, failed saves and detached active-session handoff. The existing create/relaunch UI journey now also creates, saves, reopens and starts Smart Selection. Both products use the same functional journeys.

Initial implementation results on 6 November 2026, Xcode 27.1 / iOS 26.4 Simulator:

| Check | OnlyBody | OnlyWeights |
|---|---|---|
| Swift Testing unit/integration suites | PASS — 277 tests | PASS — 258 tests |
| Functional UI plan | PASS — 8 tests | PASS — 8 tests |
| Original-schema copy migration, reopen and rollback | PASS | PASS |
| Release simulator build and bundle validation | PASS | PASS |
| Temporary seed generation | PASS — 99 exercises | PASS — 105 exercises |

`Scripts/validate.sh full` completed successfully. The final OnlyBody code was additionally rebuilt and passed all 277 unit/integration tests plus the create/relaunch Smart UI journey after the direct-start and error-handling refinements. OnlyWeights's full run compiled those refinements before testing. Localization validation covers all 605 resources in five languages; strict SwiftLint, architecture boundaries and `git diff --check` pass. Catalog, canonical-key, media and bundled seed files have no diff.

Local artifacts (outside app targets):

- `/tmp/onlybody-smart-full/onlybody-Tests.xcresult`
- `/tmp/onlybody-smart-full/onlyweights-Tests.xcresult`
- `/tmp/onlybody-smart-final-body.xcresult`
- `/tmp/onlybody-smart-full.log`
- `/tmp/onlybody-smart-final-body.log`

The additional temporary simulator was deleted after the successful final check; test reports remain on disk. The HTML v008 verification reports remain historical browser-only evidence and are not native-test results.

## Shared controls and navigation follow-up

The review on 6 November identified inconsistent Back controls and missing Smart-step gestures and keyboard dismissal. The follow-up introduces `NavigationBackButton`, shared by Smart Selection, the manual builder and muscle picker; `NavigationCloseButton`, shared by modal exercise pickers; and `WorkoutNameField`, shared by both workout editors.

The name field uses the existing `KeyboardOutsideTapBridge`, Done submission and focus cleanup. Smart internal steps and replacement sheets use `BackActionSwipeBridge`; root screens retain native interactive pop through `BackSwipeBridge`. Buttons and gestures use the same back action. Internal navigation preserves the draft, and leaving a saved, unchanged preview requires no discard confirmation. Actual unsaved changes retain confirmation.

`testSmartBackGesturesAndKeyboardDismissal` covers tapping blank space beside the name field, minimum Back hit area, button/swipe step navigation, dirty exit confirmation, replacement-sheet back/dismiss gestures, and leaving an unchanged saved preview. View-model tests cover preserved draft fields, returning from edit to preview and an incomplete draft with no selected targets.

Follow-up validation: **PASS** — `Scripts/validate.sh full`, 279 OnlyBody and 260 OnlyWeights unit/integration tests, 9 functional UI tests per product (including the new gesture/keyboard regression), both Release simulator builds, bundle checks and temporary seed generation. Strict SwiftLint and architecture/localization/catalog validators pass. The catalog and media inputs remain unchanged. Debug device builds for both products succeeded and were installed on the same physical iPhone for review.

Follow-up artifacts: `/tmp/smart-navigation-full/onlybody-Tests.xcresult`, `/tmp/smart-navigation-full/onlyweights-Tests.xcresult`, `/tmp/smart-navigation-full.log`; the initial focused gesture regression is in `/tmp/smart-navigation-focused.xcresult`.

## Direct Smart setup and problem-filter review

The creation-method chooser now opens Smart Selection setup directly. The redundant New Workout muscle-picker route is removed; targets remain editable on the Smart setup screen. The create/relaunch and gesture UI journeys select targets there, and the gesture journey explicitly checks that the old picker is absent.

The user approved the multi-select problem rules in [SMART-SELECTION.md](SMART-SELECTION.md), then separately approved adding `excludedRegions` to the settings JSON with backward-compatible decoding and reopen checks. No SwiftData entity or catalog is changed. Missing regions decode as an empty set; every existing configuration field remains intact. Invalid region values fail decoding without resetting records.

Conditions now uses selected chips for any number of regions, with per-region explanations and no load toggles. Older explicit load exclusions remain visible as removable chips. `SmartRegionRestrictions` explicitly covers all 194 repetition profiles and applies the union of selected exclusions. Unknown profiles fail closed when regions are selected. Generation, daily regeneration, preview replacements and active-workout replacements all use the same eligibility guard; showing or confirming legacy load conflicts cannot bypass region exclusions.

Coverage includes all 127 nonempty combinations, supported versus unsupported movement examples, old literal JSON, disk-store read/write/reopen with multiple regions, malformed data preservation, changed daily revisions and empty selections. The UI journey verifies multi-select, deselection, back navigation and persistence after app relaunch for both products. The earlier direct-route validation completed all 279 OnlyBody unit/integration and 9 UI tests; it was intentionally stopped during OnlyWeights compilation after the user approved the additional scope. The final combined validation is tracked separately below.

Final combined validation: **PASS** — `Scripts/validate.sh full` completed with exit code 0. OnlyBody passed 288 unit/integration tests and 9 functional UI tests; OnlyWeights passed 269 unit/integration tests and 9 functional UI tests. Both Release simulator builds, bundle checks, strict SwiftLint, architecture/catalog/localization checks and temporary seed generation (99 / 105 exercises) passed. All 614 localization resources cover five languages. Catalog, canonical-key, media and bundled seed files remain unchanged.

The first combined run exposed an invalid UI-test assumption: beginner Chest with no equipment and Knee + Hip exclusions correctly has no candidates in OnlyBody. The persistence/gesture UI journey now uses Foot + Hip, which permits a complete workout in both products, and a separate service regression verifies that missing equipment never weakens region exclusions. The corrected focused journeys passed in both products before the final successful full run. Some OnlyWeights XCTest steps reported animation-quiescence waits; assertions still passed, including the final Smart journey in about 50 seconds.

Both Debug device builds succeeded and were installed over the existing apps on the physical iPhone. OnlyWeights installation succeeded on retry after a transient connection failure. No app was uninstalled and no data reset was performed. This records installation, not a manual physical-device walkthrough of the new flow.

Final artifacts: `/tmp/smart-regions-full/onlybody-Tests.xcresult`, `/tmp/smart-regions-full/onlyweights-Tests.xcresult`, `/tmp/smart-regions-final.log`. Focused checks: `/tmp/smart-regions-focused-body.xcresult`, `/tmp/smart-regions-focused-weights.xcresult`. The initial failed UI report is retained at `/tmp/smart-regions-failed-body.xcresult`. Device build logs: `/tmp/smart-regions-device-body.log`, `/tmp/smart-regions-device-weights.log`.
