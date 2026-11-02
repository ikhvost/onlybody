import SwiftUI

struct WorkoutMuscleSummaryView: View {
    let summary: WorkoutMuscleSummary

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space16) {
            Text(.uiDesignFocus).font(Theme.fontSans(Theme.typeCard, .bold))
            if summary.ranked.isEmpty { Text(.uiNoMuscleGroupsSpecified).foregroundStyle(Theme.text2) }
            ForEach(summary.ranked, id: \.muscle) { item in
                VStack(spacing: Theme.space8) {
                    HStack {
                        Text(CatalogLocalization.label(item.muscle))
                        Spacer()
                        Text(item.sets, format: .number).font(Theme.fontMono(Theme.typeBody))
                    }
                    ProgressView(value: Double(item.sets), total: Double(summary.ranked.first?.sets ?? 1))
                        .tint(Theme.accent).accessibilityHidden(true)
                }
            }
            Text(.uiDesignMuscleBasis).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            if summary.diagram.hasHighlightedRegions {
                MuscleAnatomyView(diagram: summary.diagram, image: Image(.muscleAnatomy))
                    .accessibilityHidden(true)
                HStack(spacing: Theme.space16) {
                    MuscleDiagramLegendItem(title: String(localized: .uiPrimary), color: Theme.accent)
                    MuscleDiagramLegendItem(title: String(localized: .uiSecondary), color: Theme.muscleDiagramSecondary)
                }
                Text(summary.secondary.map { CatalogLocalization.label($0) }.joined(separator: " · "))
                    .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            }
            if summary.missingExercises > 0 { Text(.uiDesignMissingExercises).foregroundStyle(Theme.text2) }
        }
        .accessibilityIdentifier("overview.muscles")
    }
}
