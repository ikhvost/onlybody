import SwiftUI

struct ActiveWorkoutProgressBar: View {
    let currentIndex: Int
    let totalCount: Int

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Theme.surface2)
                .frame(height: 2)

            Rectangle()
                .fill(Theme.accent)
                .frame(height: 2)
                .containerRelativeFrame(.horizontal) { width, _ in
                    width * CGFloat(currentIndex) / CGFloat(max(1, totalCount))
                }
                .animation(.easeInOut(duration: 0.4), value: currentIndex)
        }
    }
}
