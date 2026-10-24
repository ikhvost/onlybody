# Exercise catalog and difficulty

The release catalog contains 65 bodyweight exercises. `SeedData.json` is authoring input only: the app reads bundled SQLite and generated Swift metadata, never JSON.

## Difficulty

Every entry explicitly declares `beginner`, `intermediate`, or `advanced`: 28 Beginner, 29 Intermediate and 8 Advanced exercises. These are relative progression levels for the named variation, based on strength, balance, coordination and support requirements. They are not personalized prescriptions and do not measure a person's fitness. Volume, tempo, range and technique can change the actual demand.

Beginner includes supported movements and basic bilateral patterns. Intermediate includes unsupported upper-body strength, single-leg work, dynamic core and jumping movements. Advanced includes demanding unilateral progressions, inverted pressing and high-tension gymnastics variants. The classifications are OnlyBody editorial decisions, informed by the [NASM exercise library](https://www.nasm.org/workout-exercise-guidance) and the exact demonstrated variants, rather than a universal standard. For example, assisted pull-ups and unsupported pull-ups have different requirements.

Run `python3 Scripts/StoreGenerator/generate-difficulties.py` after editing levels. Its `--check` mode is included in `Scripts/validate.sh`. Library groups entries in progression order and combines difficulty, muscle and search filters; the builder picker offers the same difficulty filter. Older custom names without catalog metadata appear as Unrated rather than receiving an invented level.

## Release updates without losing user data

Regenerate the bundled SQLite store with the command in `AGENTS.md`. Re-running generation replaces the seed exercises atomically; it refuses output stores containing workouts or sessions. On a fresh install it is still copied into Documents. On an existing install, `BundledExerciseCatalog` reads the release store through a disposable temporary copy and detaches its snapshots. This lets SQLite create WAL sidecars without writing inside the read-only app bundle. The temporary copy is removed after reading. The exercise repository merges release entries with stored exercises by exact name, preserving existing exercise IDs and retaining older entries. No bulk insertion or replacement of the user's database occurs at launch.

When saving a workout containing a newly introduced catalog exercise, the workout repository materializes only that selected entry in the same atomic save as the workout. It validates the entry against the injected release catalog; missing arbitrary IDs still fail. Rollback also removes any newly materialized entry. Existing workout and history relationships remain untouched. Names are the compatibility mapping, so renaming an existing catalog entry requires a deliberate alias migration.

The old `frequencyPreference` field remains solely for SwiftData store compatibility and detached round trips. There are no frequency controls, save actions or ranking/exclusion rules. All new seed values are `normal`; previously saved `more`, `less` and `never` values are ignored by generation.

## New exercises in this release

Scapular Push-Ups, Scapular Pull-Ups, Close-Grip Push-Ups, Bird Dog, Hollow Body Hold, Bicycle Crunches, Flutter Kicks, Hanging Knee Raises, Wall Sit, Lateral Lunges, Jump Squats, Donkey Kicks, Fire Hydrants, Bear Crawl, High Knees and Bent-Knee Calf Raises.

Each uses the existing offline muscle map and an official embedded YouTube demonstration. Media evidence and author links live in `Scripts/ExerciseMedia/README.md` and `catalog.json`.

## Verification

On 2026-10-24, `Scripts/validate.sh` passed: architecture boundaries, generated media/difficulty coverage, SwiftLint with zero violations, 166 Swift Testing tests in 22 suites, all five E2E journeys, Release build and temporary seed generation. Repeated generation was separately checked to retain exactly 65 unique exercises. Upgrade tests verify preserved exercise IDs, old workouts/history, file-store reopening, on-demand insertion and rollback.

Manual iPhone 17 Simulator review used the previous isolated 49-exercise store without resetting it: Library showed the expanded levels and new Bird Dog details while the underlying store still contained 49 exercise rows. Advanced filtering, level badges, muscle highlights and absence of frequency controls were checked. The E2E navigation journey additionally exercises combined search and difficulty selection, keyboard dismissal and navigation after opening the new movement.

## Workout timing

Workout templates now persist optional `durationMinutes` and `restSeconds` alongside their per-movement settings. Optional fields permit lightweight migration of older stores: the editor defaults an absent target to 30 minutes, retains existing movement rest values and derives a uniform default rest when possible. Explicitly choosing a global rest updates existing movements and the default for added/generated movements. Historical sessions retain their actual elapsed duration and per-set results.

The duration wheel offers 15–60 minutes in five-minute steps; rest offers 15–180 seconds in fifteen-second steps. Duration is a Smart-generation budget or a manual planning target, never a forced end timer. The estimate remains based on configured sets and rest, so it can differ from the target. Draft comparison includes both timing settings.

## Product catalogs

OnlyBody keeps its 65-entry authoring file and bundled store. OnlyWeights's initial 16-entry authoring file is `OnlyWeights/SeedData.json`; the two product stores are generated independently. Equipment and metadata use the shared domain taxonomy. Difficulty is a qualitative editorial classification of technique complexity, not a load prescription.

OnlyWeights examples were checked against [NASM's bench press reference](https://www.nasm.org/resource-center/exercise-library/barbell-bench-press) and [seated leg curl reference](https://www.nasm.org/workout-exercise-guidance/how-to-seated-leg-curl). Muscle highlights represent selected primary and supporting groups in the app's coarse taxonomy, not measured activation or an exhaustive list of stabilizers. No videos are supplied in the initial Gym catalog.

From the repository root, regenerate OnlyWeights metadata and seed with:

```sh
python3 Scripts/StoreGenerator/generate-difficulties.py --seed Scripts/StoreGenerator/OnlyWeights/SeedData.json --output onlybody/Products/OnlyWeights/Catalog/ExerciseDifficultyCatalog.swift
python3 Scripts/StoreGenerator/generate-muscles.py --seed Scripts/StoreGenerator/OnlyWeights/SeedData.json --output onlybody/Products/OnlyWeights/Catalog/ExerciseMuscleCatalog.swift
python3 Scripts/ExerciseMedia/generate.py --seed Scripts/StoreGenerator/OnlyWeights/SeedData.json --catalog Scripts/ExerciseMedia/onlyweights.json --output onlybody/Products/OnlyWeights/Catalog/ExerciseDemonstrationCatalog.swift --allow-missing
swift run --package-path Scripts/StoreGenerator StoreGenerator onlybody/Products/OnlyWeights/Resources/SeedStore/default.store Scripts/StoreGenerator/OnlyWeights/SeedData.json
python3 Scripts/Validation/check-catalogs.py
```

Without arguments, the metadata scripts still target OnlyBody. OnlyBody continues to require complete verified video coverage; `--allow-missing` permits a partial or empty OnlyWeights media catalog but still rejects duplicate or unknown exercise names and invalid entries. Existing exercise names remain the compatibility keys within each product. Never use a user's store as generator output.
