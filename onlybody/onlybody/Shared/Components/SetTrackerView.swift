import SwiftUI

struct SetTrackerView: View {
    let total: Int
    let completed: Int
    let current: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<total, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index < completed ? Theme.accent : (index == current ? Theme.accentDim : Theme.surface2))
                    .overlay {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(index == current ? Theme.accent : Theme.border2, lineWidth: 1.5)
                    }
                    .frame(width: 13, height: 13)
                    .animation(.easeInOut(duration: 0.2), value: completed)
            }
        }
    }
}
