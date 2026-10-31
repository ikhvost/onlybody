import SwiftUI

struct WorkoutCreationView: View {
    let onManual: () -> Void
    let onSmart: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Theme.space0) {
            NavBarView(title: String(localized: .uiNewSession)) {
                Button { dismiss() } label: { ChevronIcon(isBack: true).frame(width: Theme.touchSize, height: Theme.touchSize) }
                    .accessibilityLabel(String(localized: .uiBack))
            }
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.sectionGap) {
                    Text(.uiDesignChooseMethod).font(Theme.fontSans(Theme.typeHeading, .bold))
                    WorkoutCreationChoice(title: String(localized: .uiDesignManual),
                                          hint: String(localized: .uiDesignManualHint), action: onManual)
                        .accessibilityIdentifier("creation.manual")
                    WorkoutCreationChoice(title: String(localized: .uiDesignSmart),
                                          hint: String(localized: .uiDesignSmartHint), action: onSmart)
                        .accessibilityIdentifier("creation.smart")
                }.padding(Theme.horizontalPadding)
            }.scrollIndicators(.hidden)
        }
        .foregroundStyle(Theme.text).background(Theme.bg)
        .toolbar(.hidden, for: .navigationBar)
        .background(BackSwipeBridge().allowsHitTesting(false))
    }
}
