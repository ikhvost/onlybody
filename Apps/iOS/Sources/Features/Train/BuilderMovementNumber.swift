import SwiftUI

struct BuilderMovementNumber: View {
    let viewModel: SessionBuilderViewModel
    let movement: MovementConfig
    let field: String

    var body: some View {
        WorkoutNumberInput(title: title, identifier: field,
                           text: Binding(get: { viewModel.numberText(field, movement: movement) },
                                         set: { viewModel.enterNumber($0, field: field, id: movement.id) }),
                           hasError: viewModel.numberHasError(field, id: movement.id),
                           canDecrease: field == "Sets" ? movement.sets > 1 : field == "Reps" ? movement.reps > 1 : movement.restSeconds > 15,
                           onDecrease: { viewModel.stepNumber(field, id: movement.id, increasing: false) },
                           onIncrease: { viewModel.stepNumber(field, id: movement.id, increasing: true) })
    }

    private var title: String {
        switch field {
        case "Sets": String(localized: .uiSets)
        case "Reps": String(localized: .uiReps)
        default: String(localized: .uiRest)
        }
    }
}
