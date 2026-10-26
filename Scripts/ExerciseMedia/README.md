# Exercise demonstration catalog

All 65 OnlyBody seed exercises use the official YouTube IFrame player. Only IDs, author names and start offsets ship in the app; no video files are copied. The compiled catalog has stable media keys independent of seed UUIDs. Exercise name matching is exact.

## Content review

`Reviews/` is a local, gitignored archive at the user's request. Dated report links below refer to files on the working machine and will not be available in a fresh checkout. Keep review status and dated references in the tracked authoring catalogs; generation and validation do not require the local evidence files. Back up this archive separately if needed.

**Before adding or replacing any video in either app, complete [CHECKLIST.md](CHECKLIST.md).** It covers provenance, license evidence, physical-iPhone playback, player requirements, privacy and App Review evidence. Store dated results and screenshots in `Reviews/`; cite them in the change description. Do not equate catalog validation or browser playback with full approval.

The [2026-10-24 checklist audit](Reviews/2026-10-24/REPORT.md) records all 65 OnlyBody entries, live Share → Embed evidence and remaining gaps. OnlyWeights includes 60 videos in Debug and Release at the user’s explicit request on 2026-10-25; remaining review checks are deferred. Its expanded 60-exercise library has a [candidate register and partial review](Reviews/2026-10-25/REPORT.md), with per-video description/Embed evidence and explicit outstanding checks. The production media catalog records their status as `partial-review-user-deferred`, not completed review.

## Updating content

Complete [CHECKLIST.md](CHECKLIST.md) and save dated evidence first. Then edit `catalog.json` (OnlyBody) or `onlyweights.json` (OnlyWeights), keep each existing stable key, and run the generator with the product's input/output paths. Run `python3 Scripts/ExerciseMedia/generate.py --check` for OnlyBody; use the explicit OnlyWeights arguments documented in `../StoreGenerator/README.md`. Changes ship with an app release. The app never parses this authoring JSON. `reviewStatus: browser-embed-and-visual-sample` describes only the historical scope, not completion of the new checklist.

## Player behavior

Opening Library details immediately prepares a fresh, nonpersistent WKWebView with YouTube's own Play button; there is no Load Video step. Playback requires the user's gesture in the standard player. A system network-path monitor replaces the player with a simple offline placeholder when connectivity is lost, and prepares it again without autoplay when connectivity returns. The embed preserves YouTube controls, branding and fullscreen. It uses a 240-point-high viewport, a minimum width of 200 points, inline playback and the lowercase bundle identifier as HTTPS base URL and origin. No custom content overlays the player.

Backgrounding pauses and suspends media. Returning permits manual playback without issuing a play command. If the app becomes inactive while loading, the unfinished player is discarded and is prepared again on return. Leaving details destroys the player. Load and buffering deadlines are 20 seconds; failures replace the player with a message and Retry while retaining the author, external link and exercise details. A retry creates a new session; stale callbacks cannot alter it.

Previews use static states and disable network loading. Automated tests exercise state transitions, connectivity and the Library UI without YouTube access. UI tests explicitly inject a static ready preview through a Debug-only fixture gated by an isolated test-store UUID. Production always creates the real player.

## Official integration references

Use through the official player follows [YouTube Terms of Service](https://www.youtube.com/t/terms); the selection does not assert that the underlying videos have open-content licences. Preserve the [required minimum player functionality and client identity](https://developers.google.com/youtube/terms/required-minimum-functionality). State and error handling follow the [IFrame Player API](https://developers.google.com/youtube/iframe_api_reference) and [player parameters](https://developers.google.com/youtube/player_parameters).

## OnlyWeights media catalog

`onlyweights.json` generates all 60 demonstrations for both Debug and Release, using the existing official player, author caption and error handling. There is no separate Debug candidate array, runtime JSON loading or persistence change. The user explicitly requested Release integration on 2026-10-25 and deferred the remaining checks. Each entry records `partial-review-user-deferred` and links to the dated report; this status does not establish completed review.

```bash
python3 Scripts/ExerciseMedia/generate.py \
  --seed Scripts/StoreGenerator/OnlyWeights/SeedData.json \
  --catalog Scripts/ExerciseMedia/onlyweights.json \
  --output onlybody/Products/OnlyWeights/Catalog/ExerciseDemonstrationCatalog.swift \
  --allow-missing
```

Append `--check` to verify without writing. `check-catalogs.py` uses the same inputs. Release bundle validation checks that all catalog video IDs are present in the executable or bundled dynamic libraries and that the review register is not bundled. The [dated review](Reviews/2026-10-25/REPORT.md#release-enablement) preserves the explicit decision and outstanding checks.
