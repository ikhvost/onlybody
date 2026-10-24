import Foundation
import SwiftUI

struct SessionItemRow: View {
    let item: SessionItemSnapshot
    let isLast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space0) {
            HStack(alignment: .top) {
                Text(item.exerciseName)
                    .font(Theme.fontSans(Theme.type15, .bold))
                    .foregroundStyle(Theme.text)

                Spacer()

                MonoLabel(
                    text: "\(item.setReps.reduce(0, +)) REPS TOTAL",
                    size: Theme.type10,
                    color: Theme.text3,
                    tracking: 0.3
                )
                .accessibilityIdentifier("session.total.\(item.order)")
            }
            .padding(.bottom, Theme.space6)

            ForEach(item.setReps.indices, id: \.self) { setIndex in
                MonoLabel(
                    text: "SET \(setIndex + 1) \u{00B7} \(item.setReps[setIndex]) REPS",
                    size: Theme.type10,
                    color: Theme.text3,
                    tracking: 0.3
                )
                .accessibilityIdentifier("session.set.\(item.order).\(setIndex)")
                .padding(.bottom, Theme.space2)
            }

            if !isLast {
                Rectangle()
                    .fill(Theme.border)
                    .frame(height: 1)
                    .padding(.vertical, Theme.space13)
            }
        }
    }
}
