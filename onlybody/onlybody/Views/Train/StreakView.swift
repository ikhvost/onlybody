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
                            BackIcon(color: Theme.accent, size: 16)
                            Text("Back")
                                .font(Theme.fontSans(14, .semibold))
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back to train")
                } trailing: {
                    EmptyView()
                }

                if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    MonoLabel(text: errorMessage, size: 10, color: Theme.text2, tracking: 0.4)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: Theme.space24) {
                            HStack(spacing: Theme.space8) {
                                StatCardView(
                                    label: "CURRENT",
                                    value: "\(viewModel.stats.current)",
                                    isAccent: false
                                )
                                StatCardView(
                                    label: "LONGEST",
                                    value: "\(viewModel.stats.longest)",
                                    isAccent: true
                                )
                                StatCardView(
                                    label: "TOTAL",
                                    value: "\(viewModel.stats.total)",
                                    isAccent: true
                                )
                            }

                            VStack(alignment: .leading, spacing: Theme.space10) {
                                MonoLabel(text: "Activity — Last 20 weeks", size: 10, color: Theme.text3, tracking: 1)

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
                                size: 9,
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
        .toolbar(.hidden, for: .navigationBar)
        .task { await viewModel.load() }
    }
}
