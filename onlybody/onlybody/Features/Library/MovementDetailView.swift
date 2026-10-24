import SwiftUI

struct MovementDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: MovementDetailViewModel
    var backLabel = "Back to library"

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                NavBarView {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: Theme.space4) {
                            ChevronIcon(isBack: true, color: Theme.accent, size: Theme.type16, inset: 8)
                            Text("Back")
                                .font(Theme.fontSans(Theme.type15, .semibold))
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(backLabel)
                    .accessibilityIdentifier("movement.back")
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space16) {
                        VStack(alignment: .leading, spacing: Theme.space4) {
                            ExerciseDifficultyBadge(difficulty: viewModel.exercise.difficulty)
                                .accessibilityIdentifier("movement.difficulty")

                            Text(viewModel.exercise.name)
                                .font(Theme.fontSans(Theme.type28, .heavy))
                                .tracking(-0.8)
                                .foregroundStyle(Theme.text)

                        }

                        MovementDemonstrationView(viewModel: viewModel)

                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 1)

                        VStack(alignment: .leading, spacing: Theme.space8) {
                            MonoLabel(text: "Primary muscles", size: Theme.type11, tracking: 0.8)

                            HStack(spacing: Theme.space8) {
                                Rectangle()
                                    .fill(Theme.accent)
                                    .frame(width: 8, height: 8)
                                    .clipShape(.rect(cornerRadius: 1))

                                Text(viewModel.exercise.primaryMuscleLabel)
                                    .font(Theme.fontSans(Theme.type15, .semibold))
                                    .foregroundStyle(Theme.text)
                            }
                        }

                        VStack(alignment: .leading, spacing: Theme.space8) {
                            MonoLabel(text: "Secondary", size: Theme.type11, tracking: 0.8)

                            HStack(alignment: .top, spacing: Theme.space8) {
                                Rectangle()
                                    .fill(Theme.muscleDiagramSecondary)
                                    .frame(width: 8, height: 8)
                                    .clipShape(.rect(cornerRadius: 1))
                                    .padding(.top, Theme.space4)

                                Text(viewModel.exercise.supportingMuscles.isEmpty ? "None" : viewModel.exercise.supportingMuscles.joined(separator: ", "))
                                    .font(Theme.fontSans(Theme.type14))
                                    .foregroundStyle(Theme.text2)
                            }

                            MovementMuscleDiagramView(viewModel: viewModel)
                        }

                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 1)

                        HStack(spacing: Theme.space8) {
                            Text("Equipment")
                                .font(Theme.fontSans(Theme.type14))
                                .foregroundStyle(Theme.text2)

                            Spacer()

                            Text(viewModel.exercise.equipmentLabel)
                                .font(Theme.fontMono(Theme.type14, .bold))
                                .foregroundStyle(Theme.text)
                        }

                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, Theme.space16)
                    .padding(.bottom, Theme.space24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(BackSwipeBridge().allowsHitTesting(false))
        .toolbar(.hidden, for: .navigationBar)
    }
}

#if DEBUG
#Preview("Movement Detail") {
    var exercise = ExerciseSnapshot()
    exercise.name = "Bulgarian Split Squats"
    exercise.primaryMuscle = "Quads"
    exercise.secondaryMuscles = ["Glutes"]
    exercise.equipment = ["None"]
    return MovementDetailView(
        viewModel: MovementDetailViewModel(
            exercise: exercise,
            demonstration: ExerciseDemonstrationCatalog.demonstration(for: exercise.name),
            allowsVideoLoading: false
        )
    )
    .preferredColorScheme(.dark)
}
#endif
