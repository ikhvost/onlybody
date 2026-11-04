import SwiftUI

struct BuilderTargetPicker: View {
    let viewModel: SessionBuilderViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.sectionGap) {
                Text(.uiSelectMuscleGroups).font(Theme.fontSans(Theme.typeHeading, .bold))
                FlowLayout(spacing: Theme.space8) {
                    ForEach(ExerciseCatalog.sessionTargets, id: \.self) { muscle in
                        ChipView(label: CatalogLocalization.label(muscle), isActive: viewModel.targetMuscleGroups.contains(muscle)) {
                            if viewModel.targetMuscleGroups.contains(muscle) {
                                viewModel.targetMuscleGroups.removeAll { $0 == muscle }
                            } else {
                                viewModel.targetMuscleGroups.append(muscle)
                            }
                        }
                    }
                }
            }.padding(Theme.horizontalPadding)
        }
        .safeAreaInset(edge: .bottom) {
            GlassActionButton(title: String(localized: .uiDone), action: { dismiss() }, disabled: viewModel.targetMuscleGroups.isEmpty)
                .padding(Theme.cardInset)
        }
        .foregroundStyle(Theme.text).background(Theme.bg).preferredColorScheme(.dark)
    }
}
