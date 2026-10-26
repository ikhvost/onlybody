import SwiftUI

struct MovementMuscleDiagramView: View {
    let viewModel: MovementDetailViewModel

    var body: some View {
        VStack(spacing: Theme.space12) {
            HStack(spacing: Theme.space0) {
                MonoLabel(text: String(localized: .uiFront), size: Theme.type10, tracking: 0.8)
                    .frame(maxWidth: .infinity)
                MonoLabel(text: String(localized: .uiRearView), size: Theme.type10, tracking: 0.8)
                    .frame(maxWidth: .infinity)
            }

            MuscleAnatomyView(diagram: viewModel.muscleDiagram, image: Image(.muscleAnatomy))

            HStack(spacing: Theme.space16) {
                if !viewModel.muscleDiagram.primary.isEmpty {
                    MuscleDiagramLegendItem(title: String(localized: .uiPrimary), color: Theme.accent)
                }
                if !viewModel.muscleDiagram.secondary.isEmpty {
                    MuscleDiagramLegendItem(title: String(localized: .uiSecondary), color: Theme.muscleDiagramSecondary)
                }
            }

            if viewModel.muscleDiagram.isFullBody {
                Text(.uiFullBodyMovementMainGroupsShown)
                    .font(Theme.fontSans(Theme.type11))
                    .foregroundStyle(Theme.text2)
                    .multilineTextAlignment(.center)
            } else if !viewModel.muscleDiagram.hasHighlightedRegions {
                Text(.uiNoMuscleGroupsSpecified)
                    .font(Theme.fontSans(Theme.type12))
                    .foregroundStyle(Theme.text2)
            }
        }
        .padding(Theme.space12)
        .frame(maxWidth: Theme.muscleDiagramMaximumWidth)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .strokeBorder(Theme.border, lineWidth: 1)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(viewModel.muscleDiagramDescription)
        .accessibilityIdentifier("movement.muscleDiagram")
    }
}

#if DEBUG
#Preview("Muscle diagram — push-up") {
    var exercise = ExerciseSnapshot()
    exercise.primaryMuscle = "Chest"
    exercise.secondaryMuscles = ["Triceps", "Shoulders", "Core"]
    return MovementMuscleDiagramView(
        viewModel: MovementDetailViewModel(exercise: exercise)
    )
    .padding(Theme.horizontalPadding)
    .background(Theme.bg)
}
#endif
