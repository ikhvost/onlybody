import SwiftUI

struct BuilderMovementCard: View {
    @Bindable var viewModel: SessionBuilderViewModel
    let movement: MovementConfig

    var body: some View {
        VStack(spacing: Theme.space0) {
            HStack(spacing: Theme.space10) {
                VStack(alignment: .leading, spacing: Theme.space2) {
                    Text(movement.exercise.displayName)
                        .font(Theme.fontSans(Theme.type14, .bold))
                        .foregroundStyle(Theme.text)

                    MonoLabel(
                        text: String(localized: .uiMovementSummary(movement.sets, movement.reps, movement.restSeconds)),
                        size: Theme.type10,
                        color: Theme.text3,
                        tracking: 0.4
                    )
                }

                Spacer()

                Button {
                    viewModel.removeMovement(movement.id)
                } label: {
                    RemoveIcon(color: Theme.danger, size: Theme.type16)
                }
                .buttonStyle(.plain)
                .padding(Theme.space4)
            }
            .padding(.horizontal, Theme.space13)
            .padding(.vertical, Theme.space11)

            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)

            HStack(spacing: Theme.space10) {
                StepperView(
                    label: String(localized: .uiSets),
                        identifier: "Sets",
                    value: movement.sets,
                    step: 1,
                    minValue: 1,
                    format: { "\($0)" },
                    onIncrement: { viewModel.setSets(movement.sets + 1, forMovement: movement.id) },
                    onDecrement: { viewModel.setSets(movement.sets - 1, forMovement: movement.id) }
                )

                StepperView(
                    label: String(localized: .uiReps),
                        identifier: "Reps",
                    value: movement.reps,
                    step: 1,
                    minValue: 1,
                    format: { "\($0)" },
                    onIncrement: { viewModel.setReps(movement.reps + 1, forMovement: movement.id) },
                    onDecrement: { viewModel.setReps(movement.reps - 1, forMovement: movement.id) }
                )

                StepperView(
                    label: String(localized: .uiRest),
                        identifier: "Rest",
                    value: movement.restSeconds,
                    step: 15,
                    minValue: 15,
                    format: { String(localized: .uiSecondsCount($0)) },
                    onIncrement: { viewModel.setRest(movement.restSeconds + 15, forMovement: movement.id) },
                    onDecrement: { viewModel.setRest(movement.restSeconds - 15, forMovement: movement.id) }
                )
            }
            .padding(.horizontal, Theme.space13)
            .padding(.vertical, Theme.space10)
        }
        .background(Theme.surface)
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.border, lineWidth: 1)
        }
    }
}
