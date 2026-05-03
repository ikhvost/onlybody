import SwiftUI

struct StreakView: View {
    let viewModel: StreakViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: "Streak") {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            ChevronIcon(isBack: true, color: Theme.accent, size: 16, inset: 8)
                            Text("Back")
                                .font(Theme.fontSans(15, .semibold))
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back to train")
                }

                if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    MonoLabel(text: errorMessage, size: 11, color: Theme.text2, tracking: 0.4)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            HStack(spacing: 8) {
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

                            VStack(alignment: .leading, spacing: 10) {
                                MonoLabel(text: "Activity — Last 20 weeks", size: 11, color: Theme.text3, tracking: 1)

                                VStack(spacing: 3) {
                                    ForEach(0..<7, id: \.self) { row in
                                        HStack(spacing: 3) {
                                            ForEach(0..<20, id: \.self) { col in
                                                Rectangle()
                                                    .fill(viewModel.heatmap[row][col] ? Theme.accent : Theme.surface2)
                                                    .frame(height: 9)
                                                    .clipShape(.rect(cornerRadius: 1))
                                            }
                                        }
                                    }
                                }
                                .padding(10)
                                .background(Theme.surface)
                                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                        .stroke(Theme.border, lineWidth: 1)
                                )
                            }

                            MonoLabel(
                                text: "Manage streak in Settings",
                                size: 10,
                                color: Theme.text3,
                                tracking: 1
                            )
                        }
                        .padding(.horizontal, Theme.horizontalPadding)
                        .padding(.top, 24)
                        .padding(.bottom, 24)
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }
}

private struct StatCard: View {
    let label: String
    let value: String
    let isAccent: Bool

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(Theme.fontMono(28, .medium))
                .foregroundStyle(isAccent ? Theme.accent : Theme.text3)
            MonoLabel(text: label, size: 9, color: Theme.text3, tracking: 1.2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Theme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.border, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}
