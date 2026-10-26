import SwiftUI

struct BuilderTargets: View {
    @Bindable var viewModel: SessionBuilderViewModel

    var body: some View {
        if !viewModel.targetMuscleGroups.isEmpty {
            VStack(alignment: .leading, spacing: Theme.space8) {
                MonoLabel(text: String(localized: .uiTargets), size: Theme.type11, color: Theme.text2, tracking: 0.5)

                FlowLayout(spacing: Theme.space6) {
                    ForEach(viewModel.targetMuscleGroups, id: \.self) { muscleID in
                        Text(CatalogLocalization.label(muscleID))
                .font(Theme.fontSans(Theme.type14, .semibold))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, Theme.space10)
                            .padding(.vertical, Theme.space4)
                            .background(Theme.accentDim)
                            .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
                            .overlay {
                                RoundedRectangle(cornerRadius: Theme.chipCornerRadius)
                                    .stroke(Theme.accent.opacity(0.2), lineWidth: 1)
                            }
                    }
                }
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, Theme.space16)
        }
    }
}
