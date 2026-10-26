# App icons and launch marks

Run `bash Scripts/AppIcon/generate.sh OnlyBody` or `bash Scripts/AppIcon/generate.sh OnlyWeights` on macOS with the project toolchain. The script renders `OBMarkView` / `OWMarkView` through SwiftUI ImageRenderer with the bundled DM Sans font. It replaces the opaque 1024px app icon and transparent 1x/2x/3x launch marks. No external artwork or fonts are downloaded.

Colors and proportions live in `Theme.swift`: near-black background, silver B and medium-gray O. The native launch storyboard mirrors `brandBackground` (0.02 white) and `brandLaunchMarkSize` (112pt); update those storyboard values if the tokens change. iOS supplies the icon's corner mask.

The system launch screen displays the same mark while the app starts. There is no additional timed SwiftUI splash overlay or artificial startup delay.
