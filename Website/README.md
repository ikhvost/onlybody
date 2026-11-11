# Website

Static source for `onlybody.app`. Edit HTML/CSS in `dist/`; there is no build step or JavaScript. Publish **only `Website/dist`**.

## Preview and deploy

```sh
python3 -m http.server 8765 --bind 127.0.0.1 --directory Website/dist
```

Cloudflare Pages configuration: branch `main`, framework None, repository root, build command `exit 0`, output `Website/dist`. Connect `onlybody.app` through Custom domains. Verify HTTPS, `/privacy/`, `/terms/`, `_headers`, `_redirects` and support email after deployment; a local preview does not verify hosting configuration.

Keep `<!--email_off-->` comments around email links: the site's CSP blocks Cloudflare's JavaScript email decoding. Do not enable analytics or trackers without updating the policy.

## Assets

Screenshots are real app UI with demonstration data, captured in iPhone 17 Pro Max / iOS 26.4.1 Simulator on 2026-11-03, not physical-device tests. The English-only Visual scenario uses `en_US` and these Debug fixtures:

```text
ONLYBODY_UI_FIXTURE=catalog
ONLYBODY_UI_STORE=<fresh UUID per app>
ONLYBODY_DEMONSTRATION_FIXTURE=ready
ONLYBODY_NOTIFICATION_FIXTURE=authorized
ONLYBODY_SCREENSHOT_FIXTURE=populated
ONLYBODY_SCREENSHOT_LANGUAGE=en
```

Run each product serially on the same simulator:

```sh
xcodebuild test -project Apps/iOS/Apps.xcodeproj -scheme onlybody \
  -testPlan Visual \
  -only-testing:onlybodyUITests/StoreScreenshotTests/testWebsiteScreenshots \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.4.1' \
  -parallel-testing-enabled NO \
  -resultBundlePath Release/Website-OnlyBody.xcresult
# Repeat with scheme onlyweights, target onlyweightsUITests and a different result path.
xcrun xcresulttool export attachments --path Release/Website-OnlyBody.xcresult \
  --output-path Release/Website-OnlyBody-attachments
```

Use the attachment manifest to select train, workout builder, rest timer and exercise library from OnlyBody, and active workout and training log from OnlyWeights. The scenario returns to the Home screen before launch so screenshots do not carry a return-to-other-app status-bar link.

The six JPEGs are 880 × 1912, converted from 1320 × 2868 PNGs with `sips -Z 1912 -s format jpeg -s formatOptions 87 INPUT --out OUTPUT`. Their combined size is about 882 KiB. The phone frame is CSS; screenshots retain the full app viewport. Demo workouts and history are fictional, not actual training records. The video fixture does not contact YouTube.

The push-up muscle map uses the app's own anatomy image, renderer and seed metadata. Regenerate it with:

```sh
bash Website/Scripts/export-muscles.sh
```

Only referenced screenshots and maps are retained in `dist/assets`.

## Before release

- Verify public hosting, HTTPS, redirects, headers and support email; publication is not confirmed by this repository.
- Verify the working Privacy/Terms links in app Settings against the published pages; complete the [YouTube integration review](../Scripts/ExerciseMedia/CHECKLIST.md), including applicable privacy-policy agreement and consent requirements.
- Match the privacy text and App Store labels to actual hosting, email and YouTube behavior.
- Replace the two disabled store buttons with verified App Store URLs and update Coming soon, FAQ and pricing when listings are available.
