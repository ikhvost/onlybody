import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let session: Session

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: session.workoutName) {
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
                    .accessibilityLabel("Back to log")
                } trailing: {
                    Spacer().frame(width: 60)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space16) {
                        MonoLabel(text: dateLabel, size: 9, color: Theme.text3, tracking: 1.0)

                        HStack(spacing: Theme.space10) {
                            Text(durationText)
                                .font(Theme.fontMono(24, .medium))
                                .foregroundStyle(Theme.accent)

                            Text(caloriesText)
                                .font(Theme.fontMono(12))
                                .foregroundStyle(Theme.text2)
                        }

                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 1)

                        MonoLabel(text: "Session details will be available in the next update.", size: 10, color: Theme.text2, tracking: 0.4)
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, Theme.space16)
                    .padding(.bottom, Theme.space24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var dateLabel: String {
        session.date.formatted(
            .dateTime
                .weekday(.wide)
                .month(.wide)
                .day()
        ).uppercased()
    }

    private var durationText: String {
        let totalSeconds = session.durationSeconds
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes):\(String(format: "%02d", seconds)) min"
    }

    private var caloriesText: String {
        if let cals = session.caloriesBurned {
            return "\(cals) kcal"
        }
        return "—"
    }
}

#Preview("Session Detail") {
    let session = Session()
    session.workoutName = "Full Body"
    session.durationSeconds = 1450
    session.caloriesBurned = 102
    session.date = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 1))!

    return SessionDetailView(session: session)
        .preferredColorScheme(.dark)
}
