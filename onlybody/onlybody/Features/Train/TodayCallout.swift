import SwiftUI

struct TodayCallout: View {
    let todaysWorkouts: [WorkoutSnapshot]

    var body: some View {
        Group {
            if todaysWorkouts.isEmpty {
                HStack {
                    Text(.uiRestDay)
                        .font(Theme.fontMono(Theme.type10))
                        .foregroundStyle(Theme.text3)
                        .tracking(1)
                    Spacer()
                }
                .padding(.horizontal, Theme.space14)
                .padding(.vertical, Theme.space10)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Theme.border2)
                        .frame(width: 2)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, Theme.space10)
            } else {
                VStack(alignment: .leading, spacing: Theme.space2) {
                    MonoLabel(text: String(localized: .uiToday), size: Theme.type10, color: Theme.accent, tracking: 1)
                    Text(todaysWorkouts.map(\.name).joined(separator: " · "))
                        .font(Theme.fontSans(Theme.type14, .bold))
                        .foregroundStyle(Theme.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.space14)
                .padding(.vertical, Theme.space10)
                .background(Theme.accentDim)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Theme.accent)
                        .frame(width: 2)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, Theme.space10)
            }
        }
    }
}
