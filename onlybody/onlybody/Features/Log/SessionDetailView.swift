import Foundation
import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let session: SessionSnapshot

    private var sortedItems: [SessionItemSnapshot] {
        (session.items).sorted { $0.order < $1.order }
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                NavBarView(title: session.workoutName) {
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
                    .accessibilityLabel("Back to log")
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space0) {
                        MonoLabel(text: formattedDate(session.date), size: Theme.type10, color: Theme.text3, tracking: 1.0)
                            .padding(.bottom, Theme.space6)

                        HStack(spacing: Theme.space10) {
                            HStack(spacing: Theme.space3) {
                                Text(Duration.seconds(session.durationSeconds).formatted(.time(pattern: .minuteSecond)))
                                    .font(Theme.fontMono(Theme.type24, .medium))
                                    .foregroundStyle(Theme.accent)
                                Text("min")
                                    .font(Theme.fontMono(Theme.type13))
                                    .foregroundStyle(Theme.text2)
                            }

                        }
                        .padding(.bottom, Theme.space24)

                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 1)
                            .padding(.bottom, Theme.space16)

                        ForEach(sortedItems.enumerated(), id: \.element.id) { index, item in
                            SessionItemRow(
                                item: item,
                                isLast: index == sortedItems.count - 1
                            )
                        }
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

    private func formattedDate(_ date: Date) -> String {
        date.formatted(
            .dateTime
                .weekday(.wide)
                .month(.wide)
                .day()
                .locale(Locale(identifier: "en_US"))
        ).uppercased()
    }
}

#if DEBUG
#Preview("Session Detail") {
    var session = SessionSnapshot()
    session.workoutName = "Full Body"
    session.durationSeconds = 1450

    session.date = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 1)) ?? .now

    var item1 = SessionItemSnapshot()
    item1.order = 0
    item1.exerciseName = "Push-Ups"
    item1.plannedSets = 3
    item1.plannedReps = 12
    item1.setReps = [12, 12, 12]

    var item2 = SessionItemSnapshot()
    item2.order = 1
    item2.exerciseName = "Pull-Ups"
    item2.plannedSets = 3
    item2.plannedReps = 8
    item2.setReps = [8, 8, 8]

    session.items = [item1, item2]

    return SessionDetailView(session: session)
        .preferredColorScheme(.dark)
}
#endif
