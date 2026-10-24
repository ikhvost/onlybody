import SwiftUI

struct StreakView: View {
    @State var viewModel: StreakViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                NavBarView(title: "Streak") {
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
                    .accessibilityLabel("Back to train")
                }

                if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    MonoLabel(text: errorMessage, size: Theme.type11, color: Theme.text2, tracking: 0.4)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: Theme.space24) {
                            HStack(spacing: Theme.space8) {
                                StatCard(
                                    label: "CURRENT",
                                    value: "\(viewModel.stats.current)",
                                    isAccent: false
                                )
                                StatCard(
                                    label: "LONGEST",
                                    value: "\(viewModel.stats.longest)",
                                    isAccent: true
                                )
                                StatCard(
                                    label: "TOTAL",
                                    value: "\(viewModel.stats.total)",
                                    isAccent: true
                                )
                            }

                            VStack(alignment: .leading, spacing: Theme.space10) {
                                MonoLabel(text: "Activity — Last 20 weeks", size: Theme.type11, color: Theme.text3, tracking: 1)

                                VStack(spacing: Theme.space3) {
                                    ForEach(0..<7, id: \.self) { row in
                                        HStack(spacing: Theme.space3) {
                                            ForEach(0..<20, id: \.self) { col in
                                                Rectangle()
                                                    .fill(viewModel.heatmap[row][col] ? Theme.accent : Theme.surface2)
                                                    .frame(height: 9)
                                                    .clipShape(.rect(cornerRadius: 1))
                                            }
                                        }
                                    }
                                }
                                .padding(Theme.space10)
                                .background(Theme.surface)
                                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                        .stroke(Theme.border, lineWidth: 1)
                                )
                            }

                            MonoLabel(
                                text: "Manage streak in Settings",
                                size: Theme.type10,
                                color: Theme.text3,
                                tracking: 1
                            )
                        }
                        .padding(.horizontal, Theme.horizontalPadding)
                        .padding(.top, Theme.space24)
                        .padding(.bottom, Theme.space24)
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .background(BackSwipeBridge().allowsHitTesting(false))
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }
}
