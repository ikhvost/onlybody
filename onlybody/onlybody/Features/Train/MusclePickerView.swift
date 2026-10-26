import SwiftUI

struct MusclePickerView: View {
    @State var viewModel: MusclePickerViewModel

    let onBuild: ([String]) -> Void
    let onSkip: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                NavBarView(title: String(localized: .uiNewSession)) {
                    Button {
                        dismiss()
                    } label: {
                        ChevronIcon(isBack: true, color: Theme.text, size: Theme.type18, inset: 8)
                    }
                    .buttonStyle(.plain)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space0) {
                        Text(.uiWhatAreYouTraining)
                            .font(Theme.fontSans(Theme.type26, .bold))
                            .tracking(-0.8)
                            .foregroundStyle(Theme.text)
                            .padding(.bottom, Theme.space5)

                        MonoLabel(text: String(localized: .uiSelectMuscleGroups), size: Theme.type11, color: Theme.text3, tracking: 1)
                            .padding(.bottom, Theme.space24)

                        FlowLayout(spacing: Theme.space8) {
                            ForEach(viewModel.muscles, id: \.self) { muscle in
                                ChipView(
                                    label: CatalogLocalization.label(muscle),
                                    isActive: viewModel.selectedMuscles.contains(muscle)
                                ) {
                                    viewModel.toggle(muscle)
                                }
                            }
                        }

                        if !viewModel.selectedMuscles.isEmpty {
                            Text(viewModel.selectionSummary)
                                .font(Theme.fontMono(Theme.type12, .medium))
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
                        onBuild(viewModel.selectedMuscles)
                    } label: {
                        HStack(spacing: Theme.space5) {
                            Text(.uiBuildSession)
                                .font(Theme.fontSans(Theme.type14, .bold))
                                .foregroundStyle(viewModel.canBuild ? Theme.accentDark : Theme.text3)
                            ChevronIcon(color: viewModel.canBuild ? Theme.accentDark : Theme.text3, size: Theme.type12, inset: 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.space12)
                        .background(viewModel.canBuild ? Theme.accent : Theme.surface2)
                        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.canBuild)

                    Button {
                        onSkip()
                    } label: {
                        Text(.uiSkipPickMovementsMyself)
                            .font(Theme.fontSans(Theme.type14))
                            .foregroundStyle(Theme.text3)
                    }
                    .accessibilityIdentifier("picker.manual")
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, Theme.space20)
            }
        }
        .background(BackSwipeBridge().allowsHitTesting(false))
        .toolbar(.hidden, for: .navigationBar)
    }
}

#if DEBUG
#Preview("Muscle Picker — empty") {
    MusclePickerView(
        viewModel: MusclePickerViewModel(),
        onBuild: { _ in },
        onSkip: {}
    )
    .preferredColorScheme(.dark)
}
#endif
