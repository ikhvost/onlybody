# OnlyBody muscle illustrations

Library movement details use one generated anatomical reference with front and back views. Primary groups are gold (`#E8A23A`), secondary groups pale blue (`#8FABB0`) at 60% opacity for less emphasis, and unselected regions stay gray. The secondary text marker and diagram legend use the same subdued color. All assets are bundled, so the diagram works offline.

## Reference and rendering

- Image: `onlybody/onlybody/Resources/Assets.xcassets/MuscleAnatomy.imageset/muscle-anatomy.png`.
- Generated with the built-in ImageGen tool on 2026-10-24. Original prompt: `generation-prompt.txt`. No third-party anatomy artwork is included.
- PNG: 1254 × 1254, transparent, unchanged from the generated output.
- SHA-256: `1d29d5095cad9500dfd1e652605fc817aab836acd4f492ab2bce5617a9af716b`.
- `MuscleRegionPaths.swift` contains the aligned boundaries in reference-image coordinates. `MuscleAnatomyView` applies color while preserving the reference's muscle texture and shading. Theme owns colors and layout metrics.
- Replacing or regenerating the reference requires checking and realigning every region boundary. A matching square image size alone does not guarantee alignment.

The nine regions match the existing catalog: Chest, Back, Shoulders, Arms, Core, Quads, Glutes, Hamstrings and Calves. They represent broad groups, not individual-muscle effort measurements. Location terminology was cross-checked against the [OpenStax muscular-system chapter review](https://openstax.org/books/anatomy-and-physiology/pages/11-chapter-review). The app uses its existing primary and secondary exercise metadata; neither the seed store nor SwiftData schema changes.

Primary wins over duplicate secondary entries. Unknown labels remain unhighlighted. `Full Body` is a movement category, so those exercises show only the explicitly listed secondary groups and a caption explaining that choice; the diagram does not invent nine prime movers.

## Reusable image template

A personal ImageGen template named **OnlyBody Muscle Map** is installed as `$artifact-template-onlybody-muscle-map`. Its retained reference and gallery preview are identical to the PNG above. Find it in the Template Gallery with `$imagegen`, or tag the template directly.

Example request:

> $artifact-template-onlybody-muscle-map Зроби карту м'язів для Standard Push-Ups. Основна група: Chest. Допоміжні: Arms, Shoulders, Core. Основні м'язи — золоті #E8A23A, допоміжні — світло-блакитні #8FABB0. Збережи позу, пропорції, передній і задній ракурси, текстуру та прозорий фон еталона. Без написів і логотипів. Зміни лише кольори потрібних м'язових ділянок.

Supply these fields for each new picture:

- Exercise name, for context only; do not print it into the artwork.
- Explicit primary and secondary groups. Use verified catalog data rather than inferring extra regions.
- Preserve the reference's canvas, front-left/back-right arrangement, anatomy, pose, scale and lighting.
- Keep unselected muscles neutral gray. Use gold for primary and pale blue for secondary. Do not color joints, hands, face or pelvic covering.
- Preserve alpha transparency. No text, diagrams, labels, arrows, equipment or extra figures.

For another in-app exercise using existing groups, no new raster image is necessary: its metadata selects the same aligned regions automatically. Generate a separate template image when a standalone illustration is needed. Do not replace the application's neutral base with a highlighted image, which would permanently color that group for every exercise.

## Verification

A nine-panel render was visually inspected for all region boundaries. Swift Testing verifies catalog mappings, precedence, unknown labels, Full Body handling, accessible descriptions and the bundled reference resolution. The bundled-store integration test checks all 49 exercises. The navigation E2E checks that the diagram exposes its accessible description.

`Scripts/validate.sh` passed on 2026-10-24: architecture checks, SwiftLint with zero warnings, 166 Swift Testing tests, all five navigation/workout E2E journeys, Release build and temporary generation of the 49-exercise seed store. The complete diagram card was also inspected in the iPhone 17 Simulator.
