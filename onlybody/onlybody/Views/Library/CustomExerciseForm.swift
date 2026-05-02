import SwiftUI

struct CustomExerciseForm: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CustomExerciseViewModel

    private let columns = [GridItem(.adaptive(minimum: 120), spacing: 8, alignment: .leading)]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: "New Exercise") {
                    GhostButton(title: "Cancel") {
                        dismiss()
                    }
                } trailing: {
                    Button {
                        Task {
                            if await viewModel.save() {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Save")
                            .font(Theme.fontSans(15, .bold))
                            .foregroundStyle(viewModel.isValid && !viewModel.isSaving ? Theme.accent : Theme.text3)
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.isValid || viewModel.isSaving)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space16) {
                        VStack(alignment: .leading, spacing: Theme.space8) {
                            MonoLabel(text: "Name", size: 10, tracking: 0.8)

                            TextField("Exercise name", text: $viewModel.name)
                                .font(Theme.fontSans(13))
                                .foregroundStyle(Theme.text)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled()
                                .padding(.horizontal, Theme.space10)
                                .padding(.vertical, Theme.space9)
                                .background(Theme.surface)
                                .overlay {
                                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                        .stroke(Theme.border2, lineWidth: 1)
                                }
                                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                        }

                        VStack(alignment: .leading, spacing: Theme.space8) {
                            MonoLabel(text: "Primary muscle", size: 10, tracking: 0.8)

                            LazyVGrid(columns: columns, alignment: .leading, spacing: Theme.space8) {
                                ForEach(viewModel.muscleOptions, id: \.self) { muscle in
                                    ChipView(label: muscle, isActive: viewModel.primaryMuscle == muscle) {
                                        viewModel.togglePrimaryMuscle(muscle)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: Theme.space8) {
                            MonoLabel(text: "Secondary muscles", size: 10, tracking: 0.8)

                            LazyVGrid(columns: columns, alignment: .leading, spacing: Theme.space8) {
                                ForEach(viewModel.muscleOptions.filter { $0 != viewModel.primaryMuscle }, id: \.self) { muscle in
                                    ChipView(label: muscle, isActive: viewModel.secondaryMuscles.contains(muscle)) {
                                        viewModel.toggleSecondaryMuscle(muscle)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: Theme.space8) {
                            MonoLabel(text: "Equipment", size: 10, tracking: 0.8)

                            LazyVGrid(columns: columns, alignment: .leading, spacing: Theme.space8) {
                                ForEach(viewModel.equipmentOptions, id: \.self) { equipment in
                                    ChipView(label: equipment, isActive: viewModel.selectedEquipment.contains(equipment)) {
                                        viewModel.toggleEquipment(equipment)
                                    }
                                }
                            }
                        }

                        if let errorMessage = viewModel.errorMessage {
                            MonoLabel(text: errorMessage, size: 10, color: Theme.danger, tracking: 0.4)
                        }
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, Theme.space16)
                    .padding(.bottom, Theme.space24)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

#Preview("Custom Exercise") {
    CustomExerciseForm(viewModel: CustomExerciseViewModel(exercises: EmptyExerciseRepository()))
        .preferredColorScheme(.dark)
}
