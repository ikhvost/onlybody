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

## Website design refresh — 3 November 2026

Aligned the website with native v006: neutral dark surfaces, system typography, gold actions, rounded panels and a floating glass header. The homepage introduces both products, shows planning, sets/rest, history and exercise discovery, and finishes with a short privacy explanation and native HTML FAQ. The two hero screenshots remain fully visible. Updated catalog counts to 65/62 and removed obsolete difficulty-filter descriptions. No scripts, third-party fonts, tracking or embedded videos were added. Privacy and Terms text is unchanged by this design revision; their shared stylesheet was refreshed.

Validation:

- `StoreScreenshotTests/testWebsiteScreenshots` passed for both schemes (45.7 s / 46.0 s), producing seven native captures each. Six selected captures are used by the homepage.
- `swiftlint lint --strict --no-cache --quiet` and `git diff --check` passed.
- `bash Website/Scripts/export-muscles.sh` completed with the current native renderer; the regenerated push-up map was visually reviewed.
- All four HTML documents have balanced tags and unique IDs; all 75 local links, assets and fragment references resolve.
- Browser layout checks at 375, 393, 768, 1024 and 1440 px found no horizontal overflow on the homepage. Privacy, Terms and 404 also passed at 393 and 1440 px.
- Visually reviewed the homepage hero, product cards, planning, rest/history, exercise library/map and FAQ; verified section links, FAQ expansion, visible keyboard focus and all images loading. Browser console contained no warnings or errors. Shared legal layouts were checked separately.
- Reduced-motion, reduced-transparency and no-blur styles are included and source-reviewed; OS accessibility preferences were not changed for this review.

Local, gitignored results and browser captures are in `Release/Artifacts/2026-11-03-website/`; final native result bundles use the `*-CleanScreens.xcresult` names. Shipping app source is unchanged. This revision does not deploy the website or verify public hosting.

## Before release

- Verify public hosting, HTTPS, redirects, headers and support email; publication is not confirmed by this repository.
- Verify the working Privacy/Terms links in app Settings against the published pages; complete the [YouTube integration review](../Scripts/ExerciseMedia/CHECKLIST.md), including applicable privacy-policy agreement and consent requirements.
- Match the privacy text and App Store labels to actual hosting, email and YouTube behavior.
- Replace the two disabled store buttons with verified App Store URLs and update Coming soon, FAQ and pricing when listings are available.

## Privacy copy review — 3 November 2026

Shortened the policy body from 1,283 to 525 whitespace-delimited words and reduced eight numbered sections to five plain headings. Removed the obsolete ATT/local-video-consent workflow, withdrawal instructions, external video button, OAuth account-access link, repeated explanations and implementation details. The short video disclosure retains actual network timing, Google processing and policy links because embedded playback remains in the apps. This copy update does not establish that the app meets every agreement/consent requirement; public deployment is separate.

Compared [Rubber Bands’ short data guide](https://rubberbands.app/guide/your-data), its [full policy](https://rubberbands.app/privacy-policy), [RepCount](https://www.repcountapp.com/privacy) and [Strong](https://help.strongapp.io/article/232-privacy-policy). Used their presentation as a reference, not their differing data practices. Checked the [YouTube developer policy, III.A](https://developers.google.com/youtube/terms/developer-policies) and [EU transparency guidance](https://commission.europa.eu/law/law-topic/data-protection/information-individuals_en). Retained controller/contact, purposes and legal bases, recipients/transfers, retention and rights in concise language.

Validation: balanced HTML and unique IDs across all four pages; all 53 internal links/anchors resolve; obsolete video-consent copy is absent and email protection comments remain. Local browser review at desktop and 393 px found no horizontal overflow; the video-section link works. Screenshots are local and gitignored in `Release/Artifacts/2026-11-03-privacy/`. No native app code changed in this website revision; native validation is recorded in `Design/IMPLEMENTATION.md`.
