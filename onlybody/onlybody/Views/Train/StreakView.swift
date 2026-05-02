import SwiftUI

struct StreakView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: "Streak") {
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
                    VStack(spacing: Theme.space24) {
                        statCards

                        heatmapSection

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

    private var statCards: some View {
        HStack(spacing: Theme.space8) {
            StatCardView(label: "CURRENT", value: "—", isAccent: false)
            StatCardView(label: "LONGEST", value: "—", isAccent: true)
            StatCardView(label: "TOTAL", value: "—", isAccent: true)
        }
    }

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: Theme.space10) {
            MonoLabel(text: "Activity — Last 20 weeks", size: 10, color: Theme.text3, tracking: 1)

            VStack(spacing: 3) {
                ForEach(0..<7, id: \.self) { _ in
                    HStack(spacing: 3) {
                        ForEach(0..<20, id: \.self) { _ in
                            Rectangle()
                                .fill(Theme.surface2)
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
    }
}

private struct StatCardView: View {
    let label: String
    let value: String
    let isAccent: Bool

    var body: some View {
        VStack(spacing: Theme.space3) {
            Text(value)
                .font(Theme.fontMono(28, .medium))
                .foregroundStyle(isAccent ? Theme.accent : Theme.text3)
            MonoLabel(text: label, size: 8, color: Theme.text3, tracking: 1.2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.space14)
        .background(Theme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.border, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}
