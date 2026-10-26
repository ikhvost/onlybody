import Foundation
import SwiftUI

struct SessionItemRow: View {
    let item: SessionItemSnapshot
    let isLast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space0) {
            HStack(alignment: .top) {
                Text(CatalogLocalization.exercise(item.exerciseName))
                    .font(Theme.fontSans(Theme.type15, .bold))
                    .foregroundStyle(Theme.text)

                Spacer()

                MonoLabel(
                    text: String(localized: .uiTotalReps(item.setReps.reduce(0, +))),
                    size: Theme.type10,
                    color: Theme.text3,
                    tracking: 0.3
                )
                .accessibilityIdentifier("session.total.\(item.order)")
            }
            .padding(.bottom, Theme.space6)

            ForEach(item.setReps.indices, id: \.self) { setIndex in
                MonoLabel(
                    text: String(localized: .uiSetReps(setIndex + 1, item.setReps[setIndex])),
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
