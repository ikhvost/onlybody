import SwiftUI

struct MusclePickerView: View {
    @Bindable var viewModel: MusclePickerViewModel

    let onBuild: ([String]) -> Void
    let onSkip: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: "New Session") {
                    Button {
                        dismiss()
                    } label: {
                        BackIcon(color: Theme.text, size: 18)
                    }
                    .buttonStyle(.plain)
                } trailing: {
                    EmptyView()
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("What are you training?")
                            .font(Theme.fontSans(24, .bold))
                            .tracking(-0.8)
                            .foregroundStyle(Theme.text)
                            .padding(.bottom, 5)

                        MonoLabel(text: "Select muscle groups", size: 10, color: Theme.text3, tracking: 1)
                            .padding(.bottom, Theme.space24)

                        FlowLayout(spacing: Theme.space8) {
                            ForEach(viewModel.muscles) { muscle in
                                ChipView(
                                    label: muscle.label,
                                    isActive: viewModel.selectedIDs.contains(muscle.id)
                                ) {
                                    viewModel.toggle(muscle.id)
                                }
                            }
                        }

                        if !viewModel.selectedIDs.isEmpty {
                            Text(viewModel.selectionSummary)
                                .font(Theme.fontMono(11, .medium))
                                .foregroundStyle(Theme.accent)
                                .tracking(0.5)
                                .padding(.top, Theme.space24)
                        }
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, Theme.space24)
                }
                .scrollIndicators(.hidden)

                VStack(spacing: Theme.space10) {
                    Button {
                        onBuild(viewModel.selectedIDs)
                    } label: {
                        HStack(spacing: 5) {
                            Text("Build session")
                                .font(Theme.fontSans(13, .bold))
                                .foregroundStyle(viewModel.canBuild ? Theme.accentDark : Theme.text3)
                            ForwardIcon(color: viewModel.canBuild ? Theme.accentDark : Theme.text3, size: 12)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.canBuild ? Theme.accent : Theme.surface2)
                        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canBuild)

                    Button {
                        onSkip()
                    } label: {
                        Text("Skip — pick movements myself")
                            .font(Theme.fontSans(13))
                            .foregroundStyle(Theme.text3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview("Muscle Picker — empty") {
    MusclePickerView(
        viewModel: MusclePickerViewModel(),
        onBuild: { _ in },
        onSkip: {}
    )
    .preferredColorScheme(.dark)
}
