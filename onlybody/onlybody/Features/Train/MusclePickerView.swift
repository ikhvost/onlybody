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

                        MonoLabel(text: String(localized: .uiSelectMuscleGroups), size: Theme.typeMeta, color: Theme.text3, tracking: 1)
                            .padding(.bottom, Theme.space24)

                        FlowLayout(spacing: Theme.space8) {
                            ForEach(viewModel.muscles, id: \.self) { muscle in
                                ChipView(
                                    label: CatalogLocalization.label(muscle),
                                    isActive: viewModel.selectedMuscles.contains(muscle)
                                ) {
                                    viewModel.toggle(muscle)
                                }
                                .accessibilityIdentifier("picker.muscle.\(muscle)")
                            }
                        }

                        if !viewModel.selectedMuscles.isEmpty {
                            Text(viewModel.selectionSummary)
                                .font(Theme.fontMono(Theme.typeMeta, .medium))
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
                    PrimaryButton(title: String(localized: .uiBuildSession),
                                  action: { onBuild(viewModel.selectedMuscles) }, disabled: !viewModel.canBuild)
                        .accessibilityIdentifier("picker.build")

                    Button {
                        onSkip()
                    } label: {
                        Text(.uiSkipPickMovementsMyself)
                            .font(Theme.fontSans(Theme.typeMeta))
                            .foregroundStyle(Theme.text3)
                    }
                    .frame(minHeight: Theme.touchSize)
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
