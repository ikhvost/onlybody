import SwiftUI

enum AppIcons {
    static let viewport: CGFloat = 24
    static let stroke = StrokeStyle(lineWidth: 1.8, lineCap: .square, lineJoin: .miter)
}

#if DEBUG
#Preview("Icons") {
    ScrollView {
        VStack(alignment: .leading, spacing: Theme.space24) {
            Text("All Icons")
                .font(Theme.fontSans(Theme.type20, .bold))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.space16) {
                appIconPreviewRow("Train", TrainIcon(color: .white))
                appIconPreviewRow("Log", LogIcon(color: .white))
                appIconPreviewRow("Library", LibraryIcon(color: .white))
                appIconPreviewRow("Back", ChevronIcon(isBack: true, color: .white, inset: 8))
                appIconPreviewRow("Forward", ChevronIcon(color: .white, inset: 8))
                appIconPreviewRow("Plus", PlusIcon(color: .white))
                appIconPreviewRow("Edit", EditIcon(color: .white))
                appIconPreviewRow("Remove", RemoveIcon(color: .white))
                appIconPreviewRow("Search", SearchIcon(color: .white))
                appIconPreviewRow("Chevron", ChevronIcon(color: .white))
            }

            Divider()
                .foregroundStyle(Theme.border2)

            Text("Amber Variants")
                .font(Theme.fontSans(Theme.type20, .bold))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.space16) {
                appIconPreviewRow("Train", TrainIcon(color: Theme.accent))
                appIconPreviewRow("Log", LogIcon(color: Theme.accent))
                appIconPreviewRow("Library", LibraryIcon(color: Theme.accent))
                appIconPreviewRow("Plus", PlusIcon(color: Theme.accent))
            }
        }
        .padding(Theme.horizontalPadding)
    }
    .background(Theme.bg)
}
#endif

private func appIconPreviewRow(_ label: String, _ icon: some View) -> some View {
    HStack(spacing: Theme.space10) {
        icon
        Text(label)
            .font(Theme.fontMono(Theme.type11))
            .foregroundStyle(Theme.text2)
    }
}
