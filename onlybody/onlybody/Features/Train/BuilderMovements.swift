import SwiftUI

struct BuilderMovements: View {
    @Bindable var viewModel: SessionBuilderViewModel
    @Binding var isShowingExercisePicker: Bool

    var body: some View {
        if viewModel.mode == .manual {
            VStack(alignment: .leading, spacing: Theme.space10) {
                HStack {
                    MonoLabel(text: String(localized: .uiMovements), size: Theme.type11, color: Theme.text2, tracking: 0.5)
                    Spacer()
                    Button {
                        isShowingExercisePicker = true
                    } label: {
                        HStack(spacing: Theme.space5) {
                            PlusIcon(color: Theme.accentDark, size: Theme.type13)
                            Text(.uiAdd)
                                .font(Theme.fontSans(Theme.type14, .bold))
                                .foregroundStyle(Theme.accentDark)
                        }
                        .padding(.horizontal, Theme.space12)
                        .padding(.vertical, Theme.space5)
                        .background(Theme.accent)
                        .clipShape(.rect(cornerRadius: Theme.chipCornerRadius))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("builder.add")
                }
                .padding(.horizontal, Theme.horizontalPadding)

                if viewModel.movements.isEmpty {
                    MonoLabel(
                        text: String(localized: .uiNoMovementsYet),
                        size: Theme.type11,
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
                    VStack(spacing: Theme.space6) {
                        ForEach(viewModel.movements) { movement in
                            BuilderMovementCard(viewModel: viewModel, movement: movement)
                        }
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                }
            }
            .padding(.top, Theme.space16)
        }
    }
}
