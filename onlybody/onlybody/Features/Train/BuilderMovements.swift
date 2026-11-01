import SwiftUI

struct BuilderMovements: View {
    @Bindable var viewModel: SessionBuilderViewModel
    @Binding var isShowingExercisePicker: Bool
    @Binding var dragLocation: CGPoint?

    var body: some View {
        if viewModel.mode == .manual || !viewModel.movements.isEmpty {
            VStack(alignment: .leading, spacing: Theme.space10) {
                HStack {
                    MonoLabel(text: String(localized: .uiMovements), size: Theme.typeMeta, color: Theme.text2, tracking: 0.5)
                    Spacer()
                    if viewModel.mode == .manual {
                    Button {
                        isShowingExercisePicker = true
                    } label: {
                        HStack(spacing: Theme.space5) {
                            PlusIcon(color: Theme.accentDark, size: Theme.typeMeta)
                            Text(.uiAdd)
                                .font(Theme.fontSans(Theme.typeMeta, .bold))
                                .foregroundStyle(Theme.accentDark)
                        }
                        .padding(.horizontal, Theme.space12)
                        .padding(.vertical, Theme.space5)
                        .frame(minHeight: Theme.touchSize)
                        .contentShape(.rect)
                        .background(Theme.accent)
                        .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
                    }
                    .buttonStyle(PressableButtonStyle(animates: false))
                    .accessibilityIdentifier("builder.add")
                    .frame(minHeight: Theme.touchSize)
                    }
                }
                .padding(.horizontal, Theme.horizontalPadding)

                if viewModel.movements.isEmpty {
                    MonoLabel(
                        text: String(localized: .uiNoMovementsYet),
                        size: Theme.typeMeta,
                        color: Theme.text3,
                        tracking: 0.5
                    )
                    .frame(maxWidth: .infinity)
                    .padding(Theme.space22)
                    .background(Theme.surface)
                    .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .foregroundStyle(Theme.border2)
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                } else {
                    ExerciseReorderStack(items: viewModel.movements, spacing: Theme.space6,
                                         isEnabled: !viewModel.hasInvalidNumbers && !viewModel.isSaving,
                                         dragLocation: $dragLocation, onMove: viewModel.moveMovement) { movement, handle in
                        BuilderMovementCard(viewModel: viewModel, movement: movement, reorderHandle: handle)
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                }
            }
            .padding(.top, Theme.space16)
        }
    }
}
