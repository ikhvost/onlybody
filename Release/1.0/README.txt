OnlyBody / OnlyWeights — version 1.0 release preparation

Record scope
This is a source package and the last saved local release checkpoint. Its App Store
Connect status was not rechecked live during the 2026-10-31 repository cleanup.
Do not treat the checkpoint as evidence of current approval or public availability.

Both signed iPhone-only 1.0 (2) builds were uploaded and selected on 2026-10-28.
OnlyBody: 6827692702 / ikhvost.onlybody
OnlyWeights: 6827693301 / ikhvost.onlyweights
The latest saved publication entry records OnlyWeights App Privacy as published
by the owner and OnlyBody as unpublished. Content Rights remained unset for both
products, and neither app was recorded as submitted. app-privacy-draft.json keeps
one per-product publication state; submission-draft.json records the open decisions.

Build 2 adds ATT gating, external YouTube links, local-consent policy version 2 and
five localized system purpose strings. The 2026-10-28 validation report records
255 OnlyBody and 230 OnlyWeights Swift tests and nine UI scenarios per product
passing after test fixes and targeted retry. Both Release builds, bundle checks
and temporary seed generation passed. Historical validation and upload evidence:
../Artifacts/2026-10-28-privacy-build/validation-summary.json

Repository validation — 2026-10-31
A fresh full Scripts/validate.sh run passed on Xcode 27.1 using iPhone 17 Pro Max /
iOS 26.4: 255 OnlyBody and 230 OnlyWeights Swift tests, nine UI scenarios per app,
shared YouTube integration tests for both schemes, both Release builds, bundle
checks, strict SwiftLint, architecture/catalog checks and temporary seed generation
(65 / 60 exercises). Local logs and summary:
/tmp/onlybody-release-commit-validation-20261031.log
/tmp/onlybody-release-commit-validation-20261031/summary.json
Media-review scope and unknowns:
Scripts/ExerciseMedia/Reviews/2026-10-31/commit-preparation.json (local, gitignored).
This validation did not inspect live App Store Connect or physical-device playback.

The 2026-10-28 local store audit records free pricing, availability in 175 regions,
non-trader status, review contact and automatic release after approval for both apps.
The owner approved ten localized marketing records, 60 iPhone screenshots and
20 Header/Search assets. Private review contact details are deliberately omitted.

Version-controlled sources
- Review/metadata.json: the copy source for two products and five languages.
- Review/screenshot-copy.json: localized screenshot headlines.
- Review/review-template.html: the local review page template.
- Review/Artwork/{render,creative,proof}.html and fonts/: editable artwork sources.
- app-privacy-draft.json, submission-draft.json and youtube-privacy-findings.md:
  the last recorded release decisions, assessment and remaining unknowns.
- apple-2.1-*.txt and google-clarification-request.txt: correspondence drafts.
  Their device/date fields are draft statements, not independently verified tests.

Local generated files
Release/Artifacts/, all artwork PNG/JPG exports, ZIP packages, Review/index.html,
Review/localizations/, artwork manifests and verification reports stay on disk and
are ignored by Git. The superseded en-US/ copy exports also remain local.
Review/localizations/ is regenerated from Review/metadata.json; do not edit the
exports as a separate copy source. The renderer font is a required source asset.

Rebuild the local owner-review package from the repository root:
1. Restore or capture local source screenshots under
   Release/Artifacts/2026-10-27-upload/Screenshots/<Product>/iPhone/<language>/.
   StoreScreenshotTests captures six screens per product/language in an isolated
   Debug store. Scripts/Release/export-screenshots.py exports passing test results.
2. Run python3 Scripts/Release/build-artwork.py to regenerate the artwork manifest.
3. Run python3 Scripts/Release/artwork-server.py and open
   http://127.0.0.1:8766/1.0/Review/Artwork/render.html to export the 60 PNG cards.
   creative.html exports the 20 Header/Search PNGs. These exports stay local.
4. Run python3 Scripts/Release/build-review.py to validate available images, export
   localized text fields and rebuild Review/index.html. It reads release statuses
   from the source JSON without overriding them and gets version/build from
   onlybody/Configuration/App.xcconfig. It does not inspect App Store Connect.
5. Optionally run python3 Scripts/Release/package-review.py to create the local ZIP
   and export-verification report once all 60 artwork cards exist.
6. Serve with python3 -m http.server 8765 --bind 127.0.0.1 --directory Release and
   open http://127.0.0.1:8765/1.0/Review/index.html#shots.

A clean checkout can generate text and the review page without local screenshots;
missing screenshot/artwork coverage is reported as pending. Image rendering and
packaging require the ignored local capture archive and artwork exports.

Screenshot data and media review
ScreenshotStoreFixture is DEBUG-only and gated by a UUID-isolated UI test store.
It creates four localized routines and 55 fictional sessions over 18 weeks without
changing the shipped catalog or normal app data. The current screenshot tests keep
embedded YouTube disabled; historical captures may differ and remain local.
The captured iPhone 17 Pro Max / iOS 26.4 screens use 1320 x 2868 pixels.
Native iPad support and iPad artwork are excluded from this release.

The owner reported YouTube playback on iPhone 15 Pro / iOS 26. This is owner-reported
historical evidence, not a new physical-device test. The mandatory media review
remains partial: Scripts/ExerciseMedia/CHECKLIST.md and the gitignored dated records
under Scripts/ExerciseMedia/Reviews/ describe the evidence requirements. Simulator
and local-player tests do not establish per-video provenance, full-audio review,
Made for Kids status or complete provider-specific processing. Keep those unknowns
explicit. This source package does not attest Content Rights or publish declarations.
