import SwiftUI

/// The same workout identity and focus hierarchy for manual and Smart plans.
struct WorkoutOverviewHeader: View {
    let name: String
    let subtitle: String
    let focus: [String]
    let nameIdentifier: String
    var isSmart = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sectionGap) {
            VStack(alignment: .leading, spacing: Theme.space8) {
                if isSmart {
                    Text(.smartSmart).font(Theme.fontMono(Theme.typeMeta, .semibold)).foregroundStyle(Theme.accent)
                }
                Text(name).font(Theme.fontSans(Theme.typeHeading, .bold)).accessibilityIdentifier(nameIdentifier)
                if !subtitle.isEmpty {
                    Text(subtitle).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                }
            }
            if !focus.isEmpty {
                VStack(alignment: .leading, spacing: Theme.space8) {
                    Text(.uiDesignFocus).foregroundStyle(Theme.text2)
                    Text(focus.map { CatalogLocalization.label($0) }.joined(separator: " · "))
                        .font(Theme.fontSans(Theme.typeCard, .bold)).foregroundStyle(Theme.accent)
                }
            }
        }
    }
}
