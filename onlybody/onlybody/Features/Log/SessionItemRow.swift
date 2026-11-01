import Foundation
import SwiftUI

struct SessionItemRow: View {
    let item: SessionItemSnapshot
    let isLast: Bool
    let weightText: (Double?) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space0) {
            HStack(alignment: .top) {
                Text(CatalogLocalization.exercise(item.exerciseName))
                    .font(Theme.fontSans(Theme.typeCard, .bold))
                    .foregroundStyle(Theme.text)

                Spacer()

                VStack(alignment: .trailing, spacing: Theme.space6) {
                    MonoLabel(
                        text: String(localized: .uiTotalReps(item.setReps.reduce(0, +))),
                        size: Theme.typeMeta,
                        color: Theme.text3,
                        tracking: 0.3
                    )
                    .accessibilityIdentifier("session.total.\(item.order)")
                    if item.setWeightsKg == nil, item.weightKg != nil {
                        Text(weightText(item.weightKg))
                            .font(Theme.fontMono(Theme.typeMeta)).foregroundStyle(Theme.accent)
                            .accessibilityIdentifier("session.legacyWeight.\(item.order)")
                    }
                }
            }
            .padding(.bottom, Theme.space6)

            ForEach(item.setReps.indices, id: \.self) { setIndex in
                HStack(spacing: Theme.space12) {
                    MonoLabel(
                        text: String(localized: .uiSetReps(setIndex + 1, item.setReps[setIndex])),
                        size: Theme.typeMeta,
                        color: Theme.text3,
                        tracking: 0.3
                    )
                    .accessibilityIdentifier("session.set.\(item.order).\(setIndex)")
                    Spacer()
                    Text(weightText(item.weightForSet(at: setIndex)))
                        .font(Theme.fontMono(Theme.typeMeta)).foregroundStyle(Theme.accent)
                        .accessibilityIdentifier("session.weight.\(item.order).\(setIndex)")
                }.padding(.bottom, Theme.space2)
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
