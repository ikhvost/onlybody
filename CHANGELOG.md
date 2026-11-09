# Changelog

Changes for OnlyBody and OnlyWeights, newest version first. Record the app version,
build number when assigned and user-facing changes for each update.

## 2.1.0 — Build 4

### Added

- Smart Selection builds a workout for your available time, training level,
  target muscles and equipment. Choose the body areas and exercises you want
  to leave out, and save the setup to reuse on scheduled days.
- Preview the day's workout before starting. Reorder or replace exercises and
  adjust sets, reps, weight and rest without changing the saved setup.
- See the active workout and rest countdown on the Lock Screen and in the
  Dynamic Island on supported iPhones. Enable rest alerts in Settings to get
  notified when it's time for the next set, even with the screen locked.

### Improved

- Smart workouts appear alongside scheduled sessions under Today. The overview
  shows the estimated duration and muscles trained, and tells you when your
  selections only allow a shorter workout.
- Use the same exercise cards and replacement picker before and during Smart
  workouts, with replacement options that account for your workout settings.

[App Store release notes in five languages](Assets/Marketing/Releases/2.1.0/README.md)
apply to both apps.

## 2.0.0 — Source checkpoint

### Added

- Workout overview with scheduled days, exercises in training order, planned set
  counts, and a breakdown and map of the muscles trained. Edit or start a workout
  directly from the overview.
- An exercise list before and during a workout, with editable reps and weight for
  each set, including completed sets. A compact rest timer stays visible while
  browsing the list or logging results.
- Drag to reorder exercises in the workout editor and during a session. Replace
  an exercise directly from its card. Changes made during a session stay in that
  session.
- 34 new OnlyBody exercises (65 → 99) and 45 new OnlyWeights exercises (60 → 105),
  with localized names, muscle and equipment details, and video demonstrations.
  OnlyWeights also updated 25 existing demonstrations.
- An App Store review link in Settings for each app.

### Improved

- System Liquid Glass tab navigation and controls, centered navigation titles,
  and larger touch targets across both apps.
- A streamlined workout editor with separate manual and automatic creation
  options, quicker access to exercise selection, and protection against losing
  unsaved edits. Each workout keeps its original style when edited.
- Equipment filters in the exercise library and picker, plus clearer exercise
  terminology across English, Ukrainian, Polish, German, and French.
- Direct access to the embedded YouTube player from exercise details, with retry
  and recovery after a lost connection. The separate in-app video consent screen
  and tracking authorization prompt were removed.

### Fixed

- Exercise defaults use the latest completed performance, and workout history
  displays the actual reps and weight for each completed set.
- Workout duration estimates and automatic exercise selection better account for
  time spent training and resting.
- Improved numeric keyboard dismissal and entry of weights starting at zero.

### Preparation record

- `v2.0.0` marks this source checkpoint. The App Store build number is pending.
- Video review remains partial. See the [media review status](Scripts/ExerciseMedia/README.md)
  for the completed browser checks and outstanding physical-iPhone playback and
  content review.

## 1.0 — Build 2

Initial version for iPhone. Both apps use version `1.0` and build `2`.

### Added in 1.0

- OnlyBody for bodyweight training with 65 exercises; OnlyWeights for gym training
  with 60 exercises and its own catalog, equipment and branding.
- Workout creation, editing and reuse, plus generated routines with configurable
  sets, repetitions, duration and rest periods.
- Set-by-set workout tracking, reps and weight logging, rest timers with sound,
  and previous exercise results available during a workout.
- Workout history, training activity, statistics and exercise history.
- Exercise search and filters, muscle diagrams, difficulty and equipment details,
  and optional YouTube demonstrations with author attribution.
- Scheduled workout reminders, notification settings, and kilogram/pound units.
- English, Ukrainian, Polish, German and French interfaces and exercise catalogs.
- On-device workout storage and offline planning and logging, without an account.
- Settings links for support, Privacy Policy and Terms of Use.

### Changed in build 2

- Embedded YouTube playback requires system tracking authorization and versioned
  local consent. Updated permission explanations in all five languages and added
  external YouTube playback choices.
- Limited both apps to iPhone.
- Improved shared navigation controls, exercise picker sizing and tap targets.

### Preparation record

- The last saved local checkpoint records both `1.0 (2)` builds uploaded and
  selected on 2026-10-28. Submission and public release were not confirmed.
- The 2026-10-31 validation record reports passing tests, lint, catalog and
  architecture checks, both Release builds, bundle checks and seed generation.
- That checkpoint still had Content Rights declarations pending for both apps
  and App Privacy publication pending for OnlyBody. YouTube media review remained
  partial; dated evidence stays in the local, gitignored
  `Scripts/ExerciseMedia/Reviews/` archive.
