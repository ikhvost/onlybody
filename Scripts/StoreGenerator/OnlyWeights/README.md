# OnlyWeights exercise catalog

The release contains **60 exercises**: the original 16 names plus 44 gym movements. Names are compatibility keys and must not be renamed without an alias migration. Metadata and the bundled seed are generated from `SeedData.json`; no JSON is loaded at runtime.

## Editorial conventions

- Difficulty describes coordination, support and technique complexity, not a prescribed load: 31 beginner, 20 intermediate and 9 advanced entries. Existing levels are preserved.
- Muscle groups are qualitative selections in the shared coarse taxonomy, not activation percentages or an exhaustive list of stabilizers. The primary filtering group is one of the highlighted primary groups.
- Weighted Pull-Ups use a pronated grip; Weighted Chin-Ups use a supinated grip. Weighted Dips use parallel bars. These three variants use a dip belt and weight plates.
- Dumbbell Shoulder Press and Dumbbell Reverse Fly are standing variants. Arnold Press is seated on an upright adjustable bench. Ab Wheel Rollout starts from the knees. Cable Woodchop is standing high-to-low. Single-leg exercises use the named dumbbell load, not bodyweight-only footage.
- Barbell and EZ-Bar equipment labels cover the bar setup; belt exercises explicitly list loose plates. Bench pressing requires a rack as well as the bench. The original Barbell Bench Press equipment was corrected to include Squat Rack without changing its name or level.
- Main references: [NASM exercise library](https://www.nasm.org/workout-exercise-guidance), [NASM deadlift](https://www.nasm.org/resource-center/exercise-library/barbell-deadlift), [PureGym exercise library](https://www.puregym.com/exercises/), plus the per-movement sources below. Reviewed 2026-10-25. External classifications need not equal our editorial difficulty scale.

## Release metadata

The sources help identify movement variants; they do not establish video licensing or a complete audiovisual review. See the [separate candidate audit](../../ExerciseMedia/Reviews/2026-10-25/REPORT.md). All 60 demonstrations are enabled in Debug and Release at the user’s explicit request on 2026-10-25. Remaining checks are deferred and retain their actual statuses in the audit.

| Exercise | Difficulty | Primary | Supporting | Equipment | Reference |
| --- | --- | --- | --- | --- | --- |
| Barbell Bench Press | intermediate | Chest, Triceps | Shoulders | Barbell, Flat Bench, Squat Rack | [Source](https://www.puregym.com/exercises/chest/bench-press/barbell-bench-press/) |
| Incline Dumbbell Press | intermediate | Chest | Shoulders, Triceps | Dumbbells, Incline Bench | [Source](https://www.puregym.com/exercises/chest/bench-press/incline-dumbbell-press/) |
| Lat Pulldown | beginner | Back | Biceps, Forearms | Lat Pulldown Machine | [Source](https://www.puregym.com/exercises/back/lat-exercises/lat-pulldown/) |
| Seated Cable Row | beginner | Back | Biceps, Shoulders, Forearms | Cable Machine | [Source](https://www.youtube.com/watch?v=lJoozxC0Rns) |
| Dumbbell Shoulder Press | intermediate | Shoulders | Triceps, Serratus | Dumbbells | [Source](https://www.puregym.com/exercises/arms-and-shoulders/shoulder-press/dumbbell-shoulder-press/) |
| Dumbbell Lateral Raise | beginner | Shoulders | — | Dumbbells | [Source](https://www.youtube.com/watch?v=8aUc9snLOxU) |
| Cable Face Pull | beginner | Shoulders, Back | Biceps | Cable Machine | [Source](https://www.puregym.com/exercises/arms-and-shoulders/rear-delt-exercises/face-pulls/) |
| Dumbbell Curl | beginner | Biceps | Forearms | Dumbbells | [Source](https://www.puregym.com/exercises/arms-and-shoulders/bicep-curl/dumbbell-bicep-curls/) |
| Cable Triceps Pushdown | beginner | Triceps | — | Cable Machine | [Source](https://www.puregym.com/exercises/arms-and-shoulders/tricep-extension/tricep-pushdowns/) |
| Barbell Back Squat | advanced | Quads, Glutes | Adductors, Core | Barbell, Squat Rack | [Source](https://www.puregym.com/exercises/legs/quad-exercises/squats/barbell-back-squat/) |
| Leg Press | beginner | Quads, Glutes | Adductors | Leg Press Machine | [Source](https://www.puregym.com/exercises/legs/quad-exercises/leg-presses/45-degree-leg-press/) |
| Barbell Romanian Deadlift | intermediate | Hamstrings, Glutes | Back, Forearms, Core | Barbell | [Source](https://www.puregym.com/exercises/legs/hamstring-exercises/deadlifts/romanian-deadlift/) |
| Leg Extension | beginner | Quads | — | Leg Extension Machine | [Source](https://www.puregym.com/exercises/legs/quad-exercises/leg-extensions/) |
| Seated Leg Curl | beginner | Hamstrings | Calves | Seated Leg Curl Machine | [Source](https://www.youtube.com/watch?v=ELOCsoDSmrg) |
| Standing Calf Raise | beginner | Calves | — | Standing Calf Raise Machine | [Source](https://www.liveleantv.com/how-to-do-standing-machine-calf-raises-toes-straight-toes-out-toes-in/) |
| Cable Crunch | beginner | Core | — | Cable Machine | [Source](https://www.youtube.com/watch?v=dkGwcfo9zto) |
| Incline Barbell Bench Press | intermediate | Chest | Shoulders, Triceps | Barbell, Incline Bench, Squat Rack | [Source](https://www.puregym.com/exercises/chest/bench-press/barbell-incline-bench-press/) |
| Dumbbell Bench Press | intermediate | Chest | Shoulders, Triceps | Dumbbells, Flat Bench | [Source](https://www.puregym.com/exercises/chest/bench-press/dumbbell-bench-press/) |
| Dumbbell Fly | intermediate | Chest | Shoulders | Dumbbells, Flat Bench | [Source](https://www.puregym.com/exercises/chest/chest-fly/dumbbell-chest-fly/) |
| Cable Chest Fly | beginner | Chest | Shoulders | Cable Machine | [Source](https://www.puregym.com/exercises/chest/chest-fly/cable-flyes/) |
| Machine Chest Press | beginner | Chest | Shoulders, Triceps | Chest Press Machine | [Source](https://www.puregym.com/exercises/chest/bench-press/seated-chest-press/) |
| Pec Deck Fly | beginner | Chest | — | Pec Deck Machine | [Source](https://www.puregym.com/exercises/chest/chest-fly/machine-fly/) |
| Barbell Bent-Over Row | intermediate | Back | Biceps, Shoulders, Forearms, Core | Barbell | [Source](https://www.puregym.com/exercises/back/rows/barbell-bent-over-row/) |
| One-Arm Dumbbell Row | beginner | Back | Biceps, Shoulders, Forearms | Dumbbells, Flat Bench | [Source](https://www.puregym.com/exercises/back/rows/single-arm-dumbbell-row/) |
| Chest-Supported Dumbbell Row | beginner | Back | Biceps, Shoulders, Forearms | Dumbbells, Incline Bench | [Source](https://www.puregym.com/exercises/back/rows/incline-row/) |
| Straight-Arm Cable Pulldown | beginner | Back | Triceps, Core | Cable Machine | [Source](https://www.puregym.com/exercises/back/lat-exercises/straight-arm-lat-pulldown/) |
| Weighted Pull-Ups | advanced | Back | Biceps, Forearms, Core | Pull-up Bar, Dip Belt, Weight Plates | [Source](https://www.liveleantv.com/how-to-do-a-weighted-chin-up/) |
| Weighted Chin-Ups | advanced | Back, Biceps | Forearms, Core | Pull-up Bar, Dip Belt, Weight Plates | [Source](https://www.liveleantv.com/how-to-do-a-weighted-chin-up/) |
| Barbell Overhead Press | intermediate | Shoulders | Triceps, Serratus, Core | Barbell, Squat Rack | [Source](https://www.puregym.com/exercises/arms-and-shoulders/shoulder-press/military-press/) |
| Arnold Press | intermediate | Shoulders | Triceps | Dumbbells, Incline Bench | [Source](https://www.puregym.com/exercises/arms-and-shoulders/shoulder-press/arnold-press/) |
| Cable Lateral Raise | beginner | Shoulders | — | Cable Machine | [Source](https://www.liveleantv.com/standing-cable-lateral-raise-exercise-demonstration-video-guide/) |
| Dumbbell Reverse Fly | beginner | Shoulders, Back | — | Dumbbells | [Source](https://www.youtube.com/watch?v=hYXnvBRA_SE) |
| Barbell Curl | beginner | Biceps | Forearms | Barbell | [Source](https://www.puregym.com/exercises/arms-and-shoulders/bicep-curl/barbell-bicep-curls/) |
| EZ-Bar Curl | beginner | Biceps | Forearms | EZ-Bar | [Source](https://www.liveleantv.com/how-to-do-a-standing-ez-bar-curl/) |
| Hammer Curl | beginner | Biceps, Forearms | — | Dumbbells | [Source](https://www.puregym.com/exercises/arms-and-shoulders/bicep-curl/hammer-curls/) |
| Incline Dumbbell Curl | beginner | Biceps | Forearms | Dumbbells, Incline Bench | [Source](https://www.puregym.com/exercises/arms-and-shoulders/bicep-curl/incline-bicep-curls/) |
| Cable Curl | beginner | Biceps | Forearms | Cable Machine | [Source](https://www.puregym.com/exercises/arms-and-shoulders/bicep-curl/cable-bicep-curls/) |
| Overhead Cable Triceps Extension | beginner | Triceps | — | Cable Machine | [Source](https://www.liveleantv.com/how-to-do-a-standing-overhead-cable-triceps-extension-with-low-pulley-rope/) |
| EZ-Bar Skull Crusher | intermediate | Triceps | — | EZ-Bar, Flat Bench | [Source](https://www.youtube.com/watch?v=BDAMt_LnmMM) |
| Close-Grip Barbell Bench Press | intermediate | Triceps, Chest | Shoulders | Barbell, Flat Bench, Squat Rack | [Source](https://www.puregym.com/exercises/chest/bench-press/close-grip-bench-press) |
| Weighted Dips | advanced | Chest, Triceps | Shoulders | Dip Bar, Dip Belt, Weight Plates | [Source](https://www.liveleantv.com/how-to-do-weighted-parallel-bar-dips/) |
| Barbell Front Squat | advanced | Quads, Glutes | Adductors, Core, Back | Barbell, Squat Rack | [Source](https://www.puregym.com/exercises/legs/quad-exercises/squats/front-squat/) |
| Barbell Deadlift | advanced | Glutes, Hamstrings | Quads, Back, Forearms, Core | Barbell | [Source](https://www.puregym.com/exercises/legs/hamstring-exercises/deadlifts/conventional-deadlift/) |
| Sumo Barbell Deadlift | advanced | Glutes, Quads, Adductors | Hamstrings, Back, Forearms, Core | Barbell | [Source](https://www.puregym.com/exercises/legs/hamstring-exercises/deadlifts/sumo-deadlift/) |
| Dumbbell Goblet Squat | beginner | Quads, Glutes | Adductors, Core | Dumbbells | [Source](https://www.liveleantv.com/dumbbell-goblet-squat-exercise-video-guide/) |
| Dumbbell Bulgarian Split Squat | intermediate | Quads, Glutes | Adductors, Core | Dumbbells, Flat Bench | [Source](https://www.puregym.com/exercises/legs/quad-exercises/squats/bulgarian-split-squat/) |
| Dumbbell Reverse Lunge | intermediate | Quads, Glutes | Hamstrings, Adductors, Core | Dumbbells | [Source](https://www.puregym.com/exercises/legs/quad-exercises/lunges/reverse-lunges/) |
| Dumbbell Walking Lunge | intermediate | Quads, Glutes | Hamstrings, Adductors, Core | Dumbbells | [Source](https://www.puregym.com/exercises/legs/quad-exercises/lunges/walking-lunges/) |
| Dumbbell Step-Up | intermediate | Quads, Glutes | Hamstrings, Core | Dumbbells, Step Platform | [Source](https://www.puregym.com/exercises/glutes/step-ups/step-ups/) |
| Dumbbell Romanian Deadlift | intermediate | Hamstrings, Glutes | Back, Forearms, Core | Dumbbells | [Source](https://www.liveleantv.com/dumbbell-romanian-deadlift-rdl/) |
| Barbell Hip Thrust | intermediate | Glutes | Hamstrings, Core | Barbell, Flat Bench | [Source](https://www.puregym.com/exercises/glutes/hip-thrusts/barbell-hip-thrust/) |
| Hack Squat | beginner | Quads, Glutes | Adductors | Hack Squat Machine | [Source](https://www.puregym.com/exercises/legs/quad-exercises/squats/hack-squat/) |
| Lying Leg Curl | beginner | Hamstrings | Calves | Lying Leg Curl Machine | [Source](https://www.puregym.com/exercises/legs/hamstring-exercises/hamstring-curls/lying-leg-curl/) |
| Hip Abduction Machine | beginner | Glutes | — | Hip Abduction Machine | [Source](https://www.puregym.com/exercises/legs/inner-outer-thigh/seated-hip-abduction/) |
| Hip Adduction Machine | beginner | Adductors | — | Hip Adduction Machine | [Source](https://www.puregym.com/exercises/legs/inner-outer-thigh/seated-hip-adduction/) |
| Seated Calf Raise | beginner | Calves | — | Seated Calf Raise Machine | [Source](https://www.puregym.com/exercises/legs/calf-exercises/seated-calf-raises/) |
| Hanging Knee Raise | intermediate | Core, Hip Flexors | Forearms | Pull-up Bar | [Source](https://www.puregym.com/exercises/abs/hanging-knee-raises/) |
| Hanging Leg Raise | advanced | Core, Hip Flexors | Forearms | Pull-up Bar | [Source](https://www.puregym.com/exercises/abs/hanging-leg-raises/) |
| Ab Wheel Rollout | advanced | Core | Serratus, Shoulders, Back | Ab Wheel | [Source](https://www.puregym.com/exercises/abs/ab-wheel-rollouts/) |
| Cable Woodchop | intermediate | Core | Shoulders | Cable Machine | [Source](https://www.liveleantv.com/3-of-the-best-exercises-youve-never-done-for-sexy-abs/) |

## Compatibility and verification

The exercise repository merges bundled entries with existing stored exercises by exact name, preserving stored UUIDs. Reads do not bulk-insert the new exercises. Saving a workout materializes its selected new exercise in the same atomic transaction. Existing history retains its saved names, repetitions and per-set weights.

`GymCatalogTests` covers all 60 records, unique IDs/names, equipment membership, difficulty/muscle coverage, diagrams, combined filtering/search, a new exercise saved across reopening and an explicit no-video fixture. `GymCatalogUpgradeTests` constructs the original 16-entry file store with different IDs from the release catalog, a workout and weighted history; it checks preserved IDs/history, read-only merge, on-demand insertion and reopening.

Run `python3 Scripts/Validation/check-catalogs.py` and the full `Scripts/validate.sh` for both schemes. OnlyWeights media generation keeps `--allow-missing`. Do not regenerate OnlyBody's bundled seed while updating this product.
