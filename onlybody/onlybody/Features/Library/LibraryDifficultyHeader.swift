import SwiftUI

struct LibraryDifficultyHeader: View {
    let section: LibraryDifficultySection

    var body: some View {
        HStack {
            MonoLabel(text: section.difficulty.label, size: Theme.typeMeta, color: Theme.text2, tracking: 1)
            Spacer()
            Text(section.exercises.count, format: .number)
                .font(Theme.fontMono(Theme.typeMeta))
                .foregroundStyle(Theme.text3)
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.vertical, Theme.space12)
        .background(Theme.surface)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("library.section.\(section.difficulty.rawValue)")
    }
}
