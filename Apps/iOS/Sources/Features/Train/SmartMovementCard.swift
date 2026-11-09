import SwiftUI

struct SmartMovementCard: View {
    let item: WorkoutItemSnapshot
    let reorderHandle: ExerciseReorderHandle
    let onReplace: () -> Void

    var body: some View {
        HStack(spacing: Theme.space8) {
            reorderHandle.accessibilityIdentifier("smart.drag.\(item.id)")
            VStack(alignment: .leading, spacing: Theme.space8) {
                Text(CatalogLocalization.exercise(item.exercise?.name ?? ""))
                    .font(Theme.fontSans(Theme.typeBody, .semibold))
                Text(.uiMovementSummary(item.sets, item.targetReps, item.restSeconds))
                    .font(Theme.fontSans(Theme.type13)).foregroundStyle(Theme.text2)
                if let rule = item.exercise?.smartMetadata?.repetitionRule, rule != .total {
                    Text(rule.label).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
            ExerciseReplaceButton(identifier: "smart.replace.\(item.id)", onReplace: onReplace)
        }
        .padding(Theme.cardInset).background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
    }
}
