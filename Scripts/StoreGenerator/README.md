# Exercise catalogs

Authoring inputs: `SeedData.json` for OnlyBody and `OnlyWeights/SeedData.json` for OnlyWeights. Apps read bundled SQLite and generated Swift metadata, never these JSON files.

Names are compatibility keys: renaming requires an alias migration. Existing installs merge bundled entries by exact name while preserving stored UUIDs and history. Saving a workout materializes selected new entries atomically; never replace a user's database. Generator models must match the app's persistence schema.

Difficulty is an editorial progression level, not a load prescription. Muscle tags are qualitative primary/supporting roles, not measured activation. See [muscle assumptions](../MuscleDiagrams/muscle-audit.md) and [OnlyWeights variants and references](OnlyWeights/README.md). The legacy `frequencyPreference` field remains for store compatibility; generation ignores saved preferences.

## Regeneration

For OnlyBody, run from the repository root:

```sh
python3 Scripts/StoreGenerator/generate-difficulties.py
python3 Scripts/StoreGenerator/generate-muscles.py
python3 Scripts/ExerciseMedia/generate.py
swift run --package-path Scripts/StoreGenerator StoreGenerator onlybody/Products/OnlyBody/Resources/SeedStore/default.store Scripts/StoreGenerator/SeedData.json
```

From the repository root, regenerate OnlyWeights metadata and seed with:

```sh
python3 Scripts/StoreGenerator/generate-difficulties.py --seed Scripts/StoreGenerator/OnlyWeights/SeedData.json --output onlybody/Products/OnlyWeights/Catalog/ExerciseDifficultyCatalog.swift
python3 Scripts/StoreGenerator/generate-muscles.py --seed Scripts/StoreGenerator/OnlyWeights/SeedData.json --output onlybody/Products/OnlyWeights/Catalog/ExerciseMuscleCatalog.swift
python3 Scripts/ExerciseMedia/generate.py --seed Scripts/StoreGenerator/OnlyWeights/SeedData.json --catalog Scripts/ExerciseMedia/onlyweights.json --output onlybody/Products/OnlyWeights/Catalog/ExerciseDemonstrationCatalog.swift --allow-missing
swift run --package-path Scripts/StoreGenerator StoreGenerator onlybody/Products/OnlyWeights/Resources/SeedStore/default.store Scripts/StoreGenerator/OnlyWeights/SeedData.json
python3 Scripts/Validation/check-catalogs.py
```

Without arguments, the metadata scripts still target OnlyBody. OnlyBody continues to require complete video coverage; `--allow-missing` permits a partial or empty OnlyWeights media catalog but still rejects duplicate or unknown exercise names and invalid entries. Existing exercise names remain the compatibility keys within each product. Never use a user's store as generator output.

For validation, generate to a new `/tmp/*.store` path. Only replace a shipping seed for an intentional catalog update. Generation refuses stores containing workouts or sessions. WAL/SHM sidecars must not be committed or bundled.

Complete the [video checklist](../ExerciseMedia/CHECKLIST.md) before media changes. Run `Scripts/validate.sh` for both schemes after catalog changes; automated checks do not complete content review.
