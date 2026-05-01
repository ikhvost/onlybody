import SwiftUI

enum AppIcons {
    static let viewport: CGFloat = 24
    static let stroke = StrokeStyle(lineWidth: 1.8, lineCap: .square, lineJoin: .miter)
    static let checkStroke = StrokeStyle(lineWidth: 2.5, lineCap: .square, lineJoin: .miter)
}

#Preview("Icons") {
    ScrollView {
        VStack(alignment: .leading, spacing: Theme.space24) {
            Text("All Icons")
                .font(Theme.fontSans(20, .bold))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.space16) {
                appIconPreviewRow("Train", TrainIcon(color: .white))
                appIconPreviewRow("Log", LogIcon(color: .white))
                appIconPreviewRow("Library", LibraryIcon(color: .white))
                appIconPreviewRow("Back", BackIcon(color: .white))
                appIconPreviewRow("Forward", ForwardIcon(color: .white))
                appIconPreviewRow("Plus", PlusIcon(color: .white))
                appIconPreviewRow("Play", PlayIcon(color: .white))
                appIconPreviewRow("Edit", EditIcon(color: .white))
                appIconPreviewRow("Remove", RemoveIcon(color: .white))
                appIconPreviewRow("Check", CheckIcon(color: .white))
                appIconPreviewRow("Search", SearchIcon(color: .white))
                appIconPreviewRow("Chevron", ChevronIcon(color: .white))
                appIconPreviewRow("Drag", DragIcon(color: .white))
            }

            Divider()
                .foregroundStyle(Theme.border2)

            Text("Amber Variants")
                .font(Theme.fontSans(20, .bold))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.space16) {
                appIconPreviewRow("Train", TrainIcon(color: Theme.accent))
                appIconPreviewRow("Log", LogIcon(color: Theme.accent))
                appIconPreviewRow("Library", LibraryIcon(color: Theme.accent))
                appIconPreviewRow("Plus", PlusIcon(color: Theme.accent))
                appIconPreviewRow("Play", PlayIcon(color: Theme.accent))
                appIconPreviewRow("Check", CheckIcon(color: Theme.accent))
            }
        }
        .padding(Theme.horizontalPadding)
    }
    .background(Theme.bg)
}

private func appIconPreviewRow(_ label: String, _ icon: some View) -> some View {
    HStack(spacing: Theme.space10) {
        icon
        Text(label)
            .font(Theme.fontMono(11))
            .foregroundStyle(Theme.text2)
    }
}
