import SwiftUI

struct SmartMovementCard: View {
    let item: WorkoutItemSnapshot
    let onReplace: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space12) {
            Text(item.exercise?.smartMetadata?.role == .main ? String(localized: .smartMain) : String(localized: .smartAccessory))
                .font(Theme.fontMono(Theme.typeMeta, .semibold)).foregroundStyle(Theme.accent)
            Text(CatalogLocalization.exercise(item.exercise?.name ?? ""))
                .font(Theme.fontSans(Theme.typeCard, .bold))
            Text(item.exercise?.primaryMuscles.map { CatalogLocalization.label($0) }.joined(separator: " · ") ?? "")
                .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            Text(.uiMovementSummary(item.sets, item.targetReps, item.restSeconds))
                .font(Theme.fontMono(Theme.typeBody))
            if let rule = item.exercise?.smartMetadata?.repetitionRule, rule != .total {
                Text(rule.label).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            }
            GhostButton(title: String(localized: .smartReplace), action: onReplace)
                .accessibilityIdentifier("smart.replace.\(item.id)")
        }.frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.cardInset).background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
    }
}
