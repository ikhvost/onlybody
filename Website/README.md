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
- Connect the disabled Privacy/Terms links in app Settings; complete the YouTube policy/consent integration and [video review](../Scripts/ExerciseMedia/CHECKLIST.md).
- Match the privacy text and App Store labels to actual hosting, email and YouTube behavior.
- Replace the two disabled store buttons with verified App Store URLs and update Coming soon, FAQ and pricing when listings are available.
