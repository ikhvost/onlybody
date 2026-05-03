# TASK-001 - App Shell And Design System Smoke Test

## Type

AFK

## User story

As a user, I can launch OnlyBody and immediately see the approved dark visual language with custom tab navigation.

## What to build

Create the initial iOS app shell for OnlyBody. This slice should be launchable on its own and should prove the core visual and navigation foundation before any data-backed feature work begins.

Build the SwiftUI app target with iOS 26.0+, Swift 6.2, strict concurrency, dark-only appearance, `Theme.swift`, `AppIcons.swift`, a custom `AppTabView`, and placeholder Train, Log, and Library root screens. The placeholders are intentionally thin, but they must use the real theme tokens, custom fonts, and custom icons so future vertical slices can build on the exact design system rather than approximations.

## Acceptance criteria

- [x] App launches on iOS 26.0+.
- [x] Swift 6.2 strict concurrency is enabled.
- [x] `Info.plist` forces dark-only appearance with `UIUserInterfaceStyle = Dark`.
- [x] DM Sans and DM Mono font files are bundled in the app target.
- [x] `Info.plist` registers bundled fonts with `UIAppFonts`.
- [x] `Theme.swift` contains the approved OnlyBody colors, font helpers, horizontal padding, corner radius, and chip corner radius from `docs/plans/2026-05-01-bodyweight-training-design.md`.
- [x] Views use `Theme.fontSans` and `Theme.fontMono` rather than SwiftUI dynamic type text styles.
- [x] `AppIcons.swift` includes all 13 approved custom icons: Train, Log, Library, Back, Forward, Plus, Play, Edit, Remove, Check, Search, Chevron, and Drag.
- [x] Icons are custom SwiftUI path/canvas views and do not use SF Symbols.
- [x] Icon stroke style matches the prototype: width 1.8, square line caps, miter joins, except CheckIcon where the approved stroke width is 2.5.
- [x] `AppTabView` uses a custom bottom navigation and does not use SwiftUI `TabView`, `Tab`, `tabItem`, or `NavigationLink`.
- [x] Bottom navigation switches between Train, Log, and Library placeholder roots.
- [x] Bottom navigation active state uses amber icon, amber mono label, and 16x2 indicator bar.
- [x] Bottom navigation inactive state uses dim icon and tertiary text label.
- [x] Placeholder roots have the correct dark background and no standard SwiftUI chrome that conflicts with the custom design.
- [x] Build succeeds with zero warnings.

## Blocked by

None - can start immediately.

## Additional references

- `docs/design.html:L22-L40` - Prototype root color, font, input, and scrollbar tokens.
- `docs/design.html:L112-L224` - Custom icon geometry, primitive components, and bottom navigation prototype.
- `docs/design.html:L830-L865` - Prototype app shell, tab switching, screen routing, and bottom nav hiding behavior.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L10-L157` - Approved design principles, palette, typography, layout, components, icons, and bottom navigation.
- `docs/plans/2026-05-01-bodyweight-training-design.md:L514-L530` - Approved navigation model and bottom-nav hiding behavior.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L3-L23` - Platform, language, framework, and architecture principles.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L26-L106` - Approved project structure and zero third-party dependency requirement.
- `docs/plans/2026-05-01-bodyweight-training-tech.md:L208-L283` - App entry point and custom navigation architecture.

## Implementation notes

- Follow `AGENTS.md` architecture and SwiftUI rules from the start.
- Keep this slice intentionally small: app shell, theme, icons, bottom nav, and placeholders only.
- Use the HTML prototype in `docs/design.html` as the geometry source for icons.
- Avoid hardcoded color literals, font sizes, and padding values in views; put tokens in `Theme.swift`.
- Do not introduce repositories, SwiftData models, or feature ViewModels in this task.
- Add SwiftUI previews for theme and icon review where practical.
