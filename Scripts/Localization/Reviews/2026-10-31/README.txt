Localization and exercise terminology review — 2026-10-31

Scope: OnlyBody (65 exercises), OnlyWeights (60 exercises); English, Ukrainian,
Polish, German and French. All 428 String Catalog resources were read, including
InfoPlist.xcstrings: 2,140 localized values, of which 625 are exercise names.
Reviewer: Codex. This is an editorial audit, not native-speaker certification.

Result: 98 localized values changed across 77 resource keys. Changes address
literal translations, incomplete movement names, grammatical agreement and
consistent UI terminology. Canonical exercise names, seed stores, persisted
history and media lookup keys remain unchanged.

Examples:
- uk: Hollow Body Hold → Утримання «човника» на спині (supine, not Superman).
- pl: reverse lunges → Zakroki; Hamstring Walkouts → Hamstring walkout.
- de: Nordic Curls and Hollow Body Hold retain established borrowed names.
- fr: Dumbbell Reverse Fly → Oiseau avec haltères; seated/prone machine curls
  use Leg curl assis / Leg curl couché; sliding curls remain a separate variant.
- UI: exercise/workout terminology, repetitions, hold instructions, streaks,
  reminders, missing-data messages and equipment labels were clarified.
- Month headers now use Calendar.standaloneMonthSymbols: Ukrainian «жовтень»
  and Polish «październik», rather than the forms used inside complete dates.
  A regression test covers current-year and past-year headers in all five locales.

audit.json contains every exercise/language decision, before/after values,
change reasons, source URLs, access limitations and the complete change list.
Its validation section records the final build/test outcome.

Web research records 57 sources. Of the 625 forms, 32 are attested directly,
3 in indexed source text, 368 have movement/term-family support and 222 remain
unconfirmed individually. These counts describe source coverage, not correctness.

Evidence is intentionally graded:
- ATTESTED: the name appears in the cited page, ignoring capitalization.
- ATTESTED_INDEXED: indexed text supports it; full-page access was incomplete.
- TERM_FAMILY: the movement or vocabulary is supported; the app phrase is an
  editorial adaptation, including grammatical number and variant qualifiers.
- UNCONFIRMED: no sufficient evidence is recorded for that exact localized
  form. Retention does not certify it as a standard local name.

The internet does not provide a single naming standard. In particular, assisted
variants, heel walkouts and descriptive bodyweight names have sparse localized
sources. Do not turn the editorial review into a claim that all 625 names were
independently verified online. The per-form evidence status is authoritative.

No instructions from web pages were used as repository instructions. Technique
descriptions were used only to distinguish exercise variants; this review does
not endorse every training or medical claim on a cited page.

Maintenance:
Keep resource keys and canonical names stable. When revising a name, preserve
equipment, assistance, posture and motion qualifiers. Prefer a trainer or sports
institution and check technique before substituting a superficially similar name.
Run Scripts/Validation/check-localizations.py and Scripts/validate.sh. Search
must continue to accept both the localized display name and canonical English.

Validation outcome: PASS
- Full Scripts/validate.sh exited 0 for both products: boundaries, catalogs,
  all five locales, strict SwiftLint, tests, Release builds, app bundles and
  temporary seed generation (65 OnlyBody / 60 OnlyWeights exercises).
- OnlyBody: 269 unit/integration tests in 51 suites and 11 UI tests passed.
- OnlyWeights: 245 unit/integration tests in 46 suites and 11 UI tests passed.
- The month-header fix landed after the main OnlyBody test compilation;
  a separate final run passed all 8 LogViewModel tests (including five locale
  cases) and its 100-screen UI matrix. Both Release builds and the complete
  OnlyWeights test run include that fix.
- Canonical/localized search passes in every language for both products.
- Selected screenshots were visually inspected on the 402-point iPhone 17 Pro
  simulator (iOS 26.4). No physical-device localization check is claimed.
- Local screenshots: Release/Localization/2026-10-31/ (gitignored).
- Full results: /tmp/onlybody-localization-validation-final/.
- Additional month-header results: /tmp/onlybody-localization-calendar/.
