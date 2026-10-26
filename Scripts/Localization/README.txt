OnlyBody and OnlyWeights localization

Languages: English (source/fallback), Ukrainian, Polish, German and French.
Both targets compile the shared onlybody/onlybody/Localizable.xcstrings catalog.
iOS selects the app language; there is no independent in-app language setting.

Edit translations in Xcode's String Catalog editor. Keep symbolic keys stable.
Use generated symbols with Text(.uiKey) or String(localized: .uiKey).
Parameterized sentences use generated functions and positional format arguments.
Count summaries use explicit labels (for example, “Reps: 12”) to avoid incorrect
plural endings. Dates and numbers use the device locale.

ExerciseSnapshot.name, muscle/equipment identifiers, stored weekday codes,
video/muscle catalog keys and session exerciseName remain canonical English.
CatalogLocalization translates names only for presentation. It has separate
exercise and label maps because equipment and exercise names can overlap.
Unknown/custom names pass through unchanged. Never replace seed names with
translated text or use translated names for history queries/video lookups.
Search accepts translated and canonical exercise names. User-entered workout
names are preserved. Video audio, author/channel names and externally hosted
policy pages are not translated by this app localization.

When adding a catalog exercise or equipment label, add a stable resource key,
all five translations, and its entry in CatalogLocalization.swift.
Validate with python3 Scripts/Validation/check-localizations.py.
Focused tests: LocalizationTests, LibraryViewModelTests and
ExerciseHistoryViewModelTests; LocalizationSmokeTests captures each language.
For this change, only focused checks were requested.

Existing Release/Artifacts/1.0 archives and Store screenshots predate these
changes. Rebuild archives and capture localized Store screenshots before upload.
The localization QA screenshots are verification evidence, not final Store art.
