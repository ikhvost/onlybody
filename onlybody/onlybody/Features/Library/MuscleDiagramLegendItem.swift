import SwiftUI

struct MuscleDiagramLegendItem: View {
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: Theme.space6) {
            Rectangle()
                .fill(color)
                .frame(width: Theme.muscleLegendMarkerSize, height: Theme.muscleLegendMarkerSize)
                .clipShape(.rect(cornerRadius: Theme.space2))
            Text(title)
                .font(Theme.fontSans(Theme.type12))
                .foregroundStyle(Theme.text2)
        }
    }
}
