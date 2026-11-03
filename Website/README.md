# Website

Static source for `onlybody.app`. Edit HTML/CSS in `dist/`; there is no build step or JavaScript. Publish **only `Website/dist`**.

## Preview and deploy

```sh
python3 -m http.server 8765 --bind 127.0.0.1 --directory Website/dist
```

Cloudflare Pages configuration: branch `main`, framework None, repository root, build command `exit 0`, output `Website/dist`. Connect `onlybody.app` through Custom domains. Verify HTTPS, `/privacy/`, `/terms/`, `_headers`, `_redirects` and support email after deployment; a local preview does not verify hosting configuration.

Keep `<!--email_off-->` comments around email links: the site's CSP blocks Cloudflare's JavaScript email decoding. Do not enable analytics or trackers without updating the policy.

## Assets

Screenshots are real app UI with demonstration data, captured in iPhone 17 / iOS 26.4.1 Simulator on 2026-10-26, not physical-device tests. Capture replacements in English with `en_US` and these Debug fixtures:

```text
ONLYBODY_UI_FIXTURE=catalog
ONLYBODY_UI_STORE=<fresh UUID per app>
ONLYBODY_DEMONSTRATION_FIXTURE=ready
ONLYBODY_NOTIFICATION_FIXTURE=authorized
```

Existing JPEGs are 804 × 1748, converted from 1206 × 2622 PNGs at quality 87. The phone frame is CSS. Demo sessions use 3 sets, 12 reps and 45-second rests; their short logged durations are not actual workouts. The video fixture does not contact YouTube.

Muscle maps use the app's own anatomy image, renderer and seed metadata. Regenerate the three maps used by the homepage with:

```sh
bash Website/Scripts/export-muscles.sh
```

Only referenced screenshots and maps are retained in `dist/assets`.

## Before release

- Verify public hosting, HTTPS, redirects, headers and support email; publication is not confirmed by this repository.
- Verify the working Privacy/Terms links in app Settings against the published pages; complete the [YouTube integration review](../Scripts/ExerciseMedia/CHECKLIST.md), including applicable privacy-policy agreement and consent requirements.
- Match the privacy text and App Store labels to actual hosting, email and YouTube behavior.
- Replace the two disabled store buttons with verified App Store URLs and update Coming soon, FAQ and pricing when listings are available.

## Privacy copy review — 3 November 2026

Shortened the policy body from 1,283 to 525 whitespace-delimited words and reduced eight numbered sections to five plain headings. Removed the obsolete ATT/local-video-consent workflow, withdrawal instructions, external video button, OAuth account-access link, repeated explanations and implementation details. The short video disclosure retains actual network timing, Google processing and policy links because embedded playback remains in the apps. This copy update does not establish that the app meets every agreement/consent requirement; public deployment is separate.

Compared [Rubber Bands’ short data guide](https://rubberbands.app/guide/your-data), its [full policy](https://rubberbands.app/privacy-policy), [RepCount](https://www.repcountapp.com/privacy) and [Strong](https://help.strongapp.io/article/232-privacy-policy). Used their presentation as a reference, not their differing data practices. Checked the [YouTube developer policy, III.A](https://developers.google.com/youtube/terms/developer-policies) and [EU transparency guidance](https://commission.europa.eu/law/law-topic/data-protection/information-individuals_en). Retained controller/contact, purposes and legal bases, recipients/transfers, retention and rights in concise language.

Validation: balanced HTML and unique IDs across all four pages; all 53 internal links/anchors resolve; obsolete video-consent copy is absent and email protection comments remain. Local browser review at desktop and 393 px found no horizontal overflow; the video-section link works. Screenshots are local and gitignored in `Release/Artifacts/2026-11-03-privacy/`. No native app code changed in this website revision; native validation is recorded in `Design/IMPLEMENTATION.md`.
