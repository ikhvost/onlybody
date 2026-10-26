# OnlyBody muscle illustrations

Library movement details use one generated anatomical reference with front and back views. Primary groups are gold (`#E8A23A`), secondary groups pale blue (`#8FABB0`) at 60% opacity for less emphasis, and unselected regions stay gray. The secondary text marker and diagram legend use the same subdued color. All assets are bundled, so the diagram works offline.

## Reference and rendering

- Image: `onlybody/onlybody/Resources/Assets.xcassets/MuscleAnatomy.imageset/muscle-anatomy.png`.
- Generated with the built-in ImageGen tool on 2026-10-24. Original prompt: `generation-prompt.txt`. No third-party anatomy artwork is included.
- PNG: 1254 × 1254, transparent, unchanged from the generated output.
- SHA-256: `1d29d5095cad9500dfd1e652605fc817aab836acd4f492ab2bce5617a9af716b`.
- `MuscleRegionPaths.swift` contains the aligned boundaries in reference-image coordinates. `MuscleAnatomyView` applies color while preserving the reference's muscle texture and shading. Theme owns colors and layout metrics.
- Replacing or regenerating the reference requires checking and realigning every region boundary. A matching square image size alone does not guarantee alignment.

The 14 regions are Chest, Back, Shoulders, Biceps, Triceps, Forearms, Serratus, Core, Quads, Glutes, Hamstrings, Calves, Hip Flexors and Adductors. `AdditionalMuscleRegionPaths.swift` separates the anterior upper-arm biceps, posterior triceps and forearms. Hip Flexors uses a schematic anterior hip projection because some flexors lie deep beneath other muscles.

`SeedData.json` stores explicit `primaryMuscles`, `secondaryMuscles` and `isFullBody` metadata for all 65 exercises. Run `python3 Scripts/StoreGenerator/generate-muscles.py` after editing it. Generated `ExerciseMuscleCatalog` resolves metadata by exact stable name for both new and existing installs. Persistent legacy fields and exercise IDs remain intact. Unknown legacy exercises retain their saved labels; the historical Arms label expands to Biceps, Triceps and Forearms without guessing a more specific role.

Primary wins over duplicate secondary entries. Unknown regions remain unhighlighted. Full Body remains a filter/category; its exercises have explicit primary and secondary regions. Filters match any primary group. The generator accepts both current groups and saved Arms targets.

See [muscle audit](muscle-audit.md) for variant assumptions and supporting references. These are qualitative programming categories, not measured effort percentages; technique changes the emphasis.

For new exercises using existing regions, update catalog metadata; no new image is needed. Never replace the neutral base with a highlighted image.
