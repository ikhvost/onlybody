import SwiftUI

struct SmartSetupView: View {
    @Bindable var viewModel: SmartSelectionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sectionGap) {
            Text(.uiTargets).font(Theme.fontSans(Theme.typeCard, .semibold))
            FlowLayout(spacing: Theme.space8) {
                ForEach(viewModel.targets, id: \.self) { target in
                    ChipView(label: CatalogLocalization.label(target), isActive: viewModel.configuration.targetMuscleGroups.contains(target)) {
                        viewModel.toggleTarget(target)
                    }.disabled(!viewModel.canToggleTarget(target))
                        .accessibilityIdentifier("smart.target.\(target)")
                }
            }
            Text(.smartTargetRule).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            if !viewModel.configuration.targetMuscleGroups.isEmpty, !viewModel.hasValidTargets {
                Text(.smartInvalidTargets).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.danger)
            }
        }
    }
}
