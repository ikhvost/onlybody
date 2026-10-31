# Marketing assets

Reusable App Store copy and editable artwork for OnlyBody and OnlyWeights.
These sources are independent of release versions; version/build history lives in
[CHANGELOG.md](../../CHANGELOG.md).

## Sources

- `metadata.json`: names, subtitles, keywords, promotional text, descriptions and
  links for both products in English, Ukrainian, Polish, German and French.
- `screenshot-copy.json`: six headline/accent pairs for each product and language.
- `review-template.html`: local preview of copy and available screenshots.
- `Artwork/render.html`: six iPhone feature cards, exported at 1320 × 2868.
- `Artwork/creative.html`: Header (3840 × 1646) and Search (1920 × 1280) banners.
- `Artwork/proof.html`: gallery of exported cards with product/language selection.
- `Artwork/fonts/DMSans-Variable.ttf`: the original renderer font.

The editable sources were recovered from Git after removal of the old Release
folder. Its ignored screenshots and generated images were deleted and are not
included here. Capture new screenshots to export artwork again.

## Preview copy

From the repository root:

```sh
python3 Scripts/Marketing/build-artwork.py
python3 Scripts/Marketing/build-review.py
python3 Scripts/Marketing/artwork-server.py
```

Open [the local preview](http://127.0.0.1:8766/index.html).
Text preview and export work without screenshots; missing images are reported as
pending. Nothing is uploaded to App Store Connect.

## Capture and export artwork

Use the existing `StoreScreenshotTests` with an isolated Debug test store, then
export a passing result for each product/language:

```sh
python3 Scripts/Release/export-screenshots.py /path/to/result.xcresult \
  Assets/Marketing/Captures/OnlyBody/iPhone/uk \
  --product OnlyBody --device iPhone --language uk
```

Captures use `Captures/<Product>/iPhone/<language>/Store/*-01-*.png` through
`*-06-*.png`, plus an exported `manifest.json` alongside `Store/`.
Run `build-artwork.py` again, then open
[the card renderer](http://127.0.0.1:8766/Artwork/render.html) and
[the banner renderer](http://127.0.0.1:8766/Artwork/creative.html).
Their export buttons save PNGs locally through the loopback server.
Inspect every language for wrapping, clipping and screenshot correctness in
[the gallery](http://127.0.0.1:8766/Artwork/proof.html).

After exporting, rebuild the preview and optionally package all feature cards and
localized text:

```sh
python3 Scripts/Marketing/build-review.py
python3 Scripts/Marketing/package-review.py
```

Packaging requires every expected card. Captures, generated manifests, text
exports, PNGs, previews and ZIPs are gitignored; source templates and copy stay
version-controlled. Keep any generated images you need in a backup before
removing local outputs.

## Add another language

1. Add a localization for each product to `metadata.json`, using the correct
   App Store `locale` and a language tag such as `es` or `pt-BR`. Translate all
   copy fields. `supported_app_languages` describes the actual app interface;
   update it only when the app itself supports the language.
2. Add the same language key under each product in `screenshot-copy.json` with
   six translated headline/accent pairs. Preserve the six screen positions.
3. Capture the app in that language once its interface translation exists, or
   use an explicitly chosen supported interface language for the screenshots.
   Store the exported captures under the matching marketing language tag.
4. Regenerate the manifest, artwork and preview, then inspect the results.

The preview, renderers, local export server and package counts derive languages
from the source data. No language list needs changing in those tools. The copy
validator retains the existing field limits; confirm current App Store
requirements separately before publication.
