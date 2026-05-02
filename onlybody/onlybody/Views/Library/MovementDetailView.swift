import SwiftUI

struct MovementDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: MovementDetailViewModel

    private let frequencyOptions = [
        (label: "Normal", value: "normal"),
        (label: "More often", value: "more"),
        (label: "Less often", value: "less"),
        (label: "Exclude", value: "never")
    ]

    private var equipmentText: String {
        let equipment = viewModel.exercise.equipment.joined(separator: ", ")
        return equipment.isEmpty ? "None" : equipment
    }

    private var secondaryMusclesText: String {
        viewModel.exercise.secondaryMuscles.isEmpty ? "None" : viewModel.exercise.secondaryMuscles.joined(separator: ", ")
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: "Movement") {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            BackIcon(color: Theme.accent, size: 16)
                            Text("Back")
                                .font(Theme.fontSans(14, .semibold))
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back to library")
                } trailing: {
                    EmptyView()
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.exercise.name)
                                .font(Theme.fontSans(26, .heavy))
                                .tracking(-0.8)
                                .foregroundStyle(Theme.text)

                            if viewModel.exercise.isCustom {
                                CustomBadgeView()
                                    .padding(.top, 4)
                            }
                        }

                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 1)

                        VStack(alignment: .leading, spacing: 8) {
                            MonoLabel(text: "Primary muscle", size: 10, tracking: 0.8)

                            HStack(spacing: 8) {
                                Rectangle()
                                    .fill(Theme.accent)
                                    .frame(width: 8, height: 8)
                                    .clipShape(.rect(cornerRadius: 1))

                                Text(viewModel.exercise.primaryMuscle)
                                    .font(Theme.fontSans(14, .semibold))
                                    .foregroundStyle(Theme.text)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            MonoLabel(text: "Secondary", size: 10, tracking: 0.8)

                            HStack(alignment: .top, spacing: 8) {
                                Rectangle()
                                    .fill(Theme.border2)
                                    .frame(width: 8, height: 8)
                                    .clipShape(.rect(cornerRadius: 1))
                                    .padding(.top, 4)

                                Text(secondaryMusclesText)
                                    .font(Theme.fontSans(13))
                                    .foregroundStyle(Theme.text2)
                            }

                            ZStack {
                                Theme.surface
                                    .overlay {
                                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                            .stroke(Theme.border, lineWidth: 1)
                                    }
                                    .clipShape(.rect(cornerRadius: Theme.cornerRadius))

                                MonoLabel(text: "[ muscle diagram ]", size: 10, tracking: 1)
                            }
                            .frame(height: 120)
                            .accessibilityLabel("Muscle diagram placeholder")
                        }

                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 1)

                        HStack(spacing: 8) {
                            Text("Equipment")
                                .font(Theme.fontSans(13))
                                .foregroundStyle(Theme.text2)

                            Spacer()

                            Text(equipmentText)
                                .font(Theme.fontMono(13, .bold))
                                .foregroundStyle(Theme.text)
                        }

                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 1)

                        VStack(alignment: .leading, spacing: 8) {
                            MonoLabel(text: "Include in sessions", size: 10, tracking: 0.8)

                            HStack(spacing: 8) {
                                ForEach(frequencyOptions, id: \.value) { option in
                                    ChipView(
                                        label: option.label,
                                        isActive: viewModel.selectedFrequency == option.value,
                                        size: 12,
                                        cornerRadius: Theme.cornerRadius,
                                        horizontalPadding: 4,
                                        verticalPadding: 9
                                    ) {
                                        Task {
                                            await viewModel.setFrequency(option.value)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .disabled(viewModel.isSaving)
                                    .accessibilityLabel("Set frequency to \(option.label)")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview("Movement Detail") {
    let exercise = Exercise()
    exercise.name = "Bulgarian Split Squats"
    exercise.primaryMuscle = "Quads"
    exercise.secondaryMuscles = ["Glutes"]
    exercise.equipment = ["None"]
    exercise.isCustom = true

    return MovementDetailView(
        viewModel: MovementDetailViewModel(
            exercise: exercise,
            exercises: EmptyExerciseRepository()
        )
    )
    .preferredColorScheme(.dark)
}
