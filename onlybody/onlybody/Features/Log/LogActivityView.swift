import SwiftUI

struct LogActivityView: View {
    let viewModel: LogViewModel

    var body: some View {
        VStack(spacing: Theme.space20) {
            HStack(spacing: Theme.space8) {
                StatCard(
                    label: String(localized: .uiDesignStreak),
                    value: "\(viewModel.stats.current)",
                    isAccent: false
                )
                StatCard(
                    label: String(localized: .uiDesignBest),
                    value: "\(viewModel.stats.longest)",
                    isAccent: true
                )
                StatCard(
                    label: String(localized: .uiDesignSessions),
                    value: "\(viewModel.stats.total)",
                    isAccent: true
                )
            }

            VStack(alignment: .leading, spacing: Theme.space10) {
                MonoLabel(text: String(localized: .uiActivityLast20Weeks), size: Theme.typeMeta, color: Theme.text3, tracking: 1)

                VStack(spacing: Theme.space3) {
                    ForEach(0..<7, id: \.self) { row in
                        HStack(spacing: Theme.space3) {
                            ForEach(0..<20, id: \.self) { col in
                                Rectangle()
                                    .fill(viewModel.heatmap[row][col] ? Theme.accent : Theme.surface2)
                                    .frame(height: Theme.activityCellHeight)
                                    .clipShape(.rect(cornerRadius: Theme.activityCellCornerRadius))
                            }
                        }
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(String(localized: .uiActivityDays(viewModel.activeDaysInHeatmap)))
                .padding(Theme.space10)
                .background(Theme.surface)
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.border, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.bottom, Theme.space24)
        .accessibilityIdentifier("log.activity")
    }
}
