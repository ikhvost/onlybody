# Exercise demonstration catalog

All 100 OnlyBody seed exercises use the official YouTube IFrame player. Only IDs, author names and start offsets ship in the app; no video files are copied. The compiled catalog has stable media keys independent of seed UUIDs. Exercise name matching is exact.

## Content review

`Reviews/` is a local, gitignored archive at the user's request. Dated report links below refer to files on the working machine and will not be available in a fresh checkout. Keep review status and dated references in the tracked authoring catalogs; generation and validation do not require the local evidence files. Back up this archive separately if needed.

**Before adding or replacing any video in either app, complete [CHECKLIST.md](CHECKLIST.md).** It covers provenance, license evidence, physical-iPhone playback, player requirements, privacy and App Review evidence. Store dated results and screenshots in `Reviews/`; cite them in the change description. Do not equate catalog validation or browser playback with full approval.

The [2026-10-24 checklist audit](Reviews/2026-10-24/REPORT.md) records all 65 OnlyBody entries, live Share → Embed evidence and remaining gaps. OnlyWeights first included 60 videos in Debug and Release at the user’s explicit request on 2026-10-25. That expansion has a [candidate register and partial review](Reviews/2026-10-25/REPORT.md), with per-video description/Embed evidence and explicit outstanding checks. The media catalog records their status as `partial-review-user-deferred`, not completed review.

## Updating content

Complete [CHECKLIST.md](CHECKLIST.md) and save dated evidence first. Then edit `catalog.json` (OnlyBody) or `onlyweights.json` (OnlyWeights), keep each existing stable key, and run the generator with the product's input/output paths. Run `python3 Scripts/ExerciseMedia/generate.py --check` for OnlyBody; use the explicit OnlyWeights arguments documented in `../StoreGenerator/README.md`. Changes ship with an app release. The app never parses this authoring JSON. `reviewStatus: browser-embed-and-visual-sample` describes only the historical scope, not completion of the new checklist.

## Player behavior

As explicitly requested on 2026-11-03, the app-level video-consent screen, ATT request and YouTube settings section have been removed. This implementation decision does not establish that all consent/tracking obligations are resolved. The website was left unchanged at the user’s request; policy wording still needs to be reconciled before release. See the [local integration checklist](Reviews/2026-11-03/native-v006-integration.json).

Opening Library details immediately prepares a fresh, nonpersistent WKWebView with YouTube's own Play button; there is no Load Video step. Playback requires the user's gesture in the standard player. A system network-path monitor replaces the player with a simple offline placeholder when connectivity is lost, and prepares it again without autoplay when connectivity returns. The embed preserves YouTube controls, branding and fullscreen. It uses a 240-point-high viewport, a minimum width of 200 points, inline playback and the lowercase bundle identifier as HTTPS base URL and origin. No custom content overlays the player.

Backgrounding pauses and suspends media. Returning permits manual playback without issuing a play command. If the app becomes inactive while loading, the unfinished player is discarded and is prepared again on return. Leaving details destroys the player. Load and buffering deadlines are 20 seconds; failures replace the player with a message and Retry while retaining the author and exercise details. The app has no separate Watch on YouTube button; links inside the official player remain intact. A retry creates a new session; stale callbacks cannot alter it.

Previews use static states and disable network loading. Automated tests exercise state transitions, connectivity and the Library UI without YouTube access. UI tests explicitly inject a static ready preview through a Debug-only fixture gated by an isolated test-store UUID. Production always creates the real player.

## Official integration references

Use through the official player follows [YouTube Terms of Service](https://www.youtube.com/t/terms); the selection does not assert that the underlying videos have open-content licences. Preserve the [required minimum player functionality and client identity](https://developers.google.com/youtube/terms/required-minimum-functionality). State and error handling follow the [IFrame Player API](https://developers.google.com/youtube/iframe_api_reference) and [player parameters](https://developers.google.com/youtube/player_parameters).

## Catalog changes

On 2026-11-11, OnlyBody gained the kneeling Ab Wheel Rollout with the existing OPEX Fitness demonstration from OnlyWeights. The [dated local review](Reviews/2026-11-11/onlybody-ab-wheel-rollout/REPORT.md) records current Share → Embed evidence and browser playback samples. The license label, full audiovisual inspection and physical-iPhone playback remain unconfirmed; its status is `browser-embed-and-visual-sample`. The integration and OnlyWeights catalog are unchanged.

`onlyweights.json` generates all 105 demonstrations for both Debug and Release, using the existing official player, author caption and error handling. There is no separate Debug candidate array, runtime JSON loading or persistence change. The original 60 entries were introduced with `partial-review-user-deferred` following the user's 2026-10-25 decision. Machine Row and Barbell Upright Row were added on 2026-11-01 with `browser-embed-and-visual-sample` and a [dated partial review](Reviews/2026-11-01/REPORT.md): expanded descriptions, channel provenance, Share → Embed and visual browser samples were inspected. Their license labels, full audiovisual review and physical-iPhone playback remain unconfirmed; no new user deferral or completed review is claimed.

On 2026-11-03, at the user's request, 25 PureGym demonstrations were replaced with OPEX Fitness (8), Bodybuilding.com (7), NASM (5), Catalyst Athletics (3) and ScottHermanFitness (2). PureGym supplied 21 of 62 videos after that review. The [dated local review](Reviews/2026-11-03/REPORT.md) retains the previous mappings, exact new titles/channel URLs, per-video checklist records and screenshots of descriptions, visual playback samples and Share → Embed. These 25 entries use `browser-embed-and-visual-sample`; explicit license labels, complete audiovisual review and physical-iPhone playback remain unconfirmed. At that point the catalog contained 27 browser-sample entries and 35 entries with the earlier deferred-review status.

On 2026-11-04, OnlyBody gained 34 exercises and OnlyWeights gained 43. All 77 final videos passed Share → Embed and started in the official player in a local browser test. Three candidates returned error 150 and were replaced before integration. The new entries use the partial review status. License labels, complete playback with sound, per-video screenshots and playback in the apps on a physical iPhone remain open. The largest channel share is 11 of 99 in OnlyBody and 21 of 105 in OnlyWeights. [Local review and playback evidence](Reviews/2026-11-04/REPORT.md).

```bash
python3 Scripts/ExerciseMedia/generate.py \
  --seed Scripts/StoreGenerator/OnlyWeights/SeedData.json \
  --catalog Scripts/ExerciseMedia/onlyweights.json \
  --output Apps/iOS/Products/OnlyWeights/Catalog/ExerciseDemonstrationCatalog.swift \
  --allow-missing
```

Append `--check` to verify without writing. `check-catalogs.py` uses the same inputs. Release bundle validation checks that all catalog video IDs are present in the executable or bundled dynamic libraries and that the review register is not bundled. The [dated review](Reviews/2026-10-25/REPORT.md#release-enablement) preserves the explicit decision and outstanding checks.
