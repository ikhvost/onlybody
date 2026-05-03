import Foundation
import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let session: Session

    private var sortedItems: [SessionItem] {
        (session.items ?? []).sorted { $0.order < $1.order }
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: session.workoutName) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            ChevronIcon(isBack: true, color: Theme.accent, size: 16, inset: 8)
                            Text("Back")
                                .font(Theme.fontSans(14, .semibold))
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back to log")
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        MonoLabel(text: formattedDate(session.date), size: 9, color: Theme.text3, tracking: 1.0)
                            .padding(.bottom, 6)

                        HStack(spacing: 10) {
                            HStack(spacing: 3) {
                                Text(Duration.seconds(session.durationSeconds).formatted(.time(pattern: .minuteSecond)))
                                    .font(Theme.fontMono(24, .medium))
                                    .foregroundStyle(Theme.accent)
                                Text("min")
                                    .font(Theme.fontMono(12))
                                    .foregroundStyle(Theme.text2)
                            }

                            HStack(spacing: 3) {
                                Text(session.caloriesBurned.map(String.init) ?? "\u{2014}")
                                    .font(Theme.fontMono(24, .medium))
                                    .foregroundStyle(Theme.text)
                                if session.caloriesBurned != nil {
                                    Text("kcal")
                                        .font(Theme.fontMono(12))
                                        .foregroundStyle(Theme.text2)
                                }
                            }
                        }
                        .padding(.bottom, 24)

                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 1)
                            .padding(.bottom, 16)

                        ForEach(sortedItems.enumerated(), id: \.element.id) { index, item in
                            SessionItemRow(
                                item: item,
                                isLast: index == sortedItems.count - 1
                            )
                        }
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
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

private struct SessionItemRow: View {
    let item: SessionItem
    let isLast: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(item.exerciseName)
                    .font(Theme.fontSans(14, .bold))
                    .foregroundStyle(Theme.text)

                Spacer()

                MonoLabel(
                    text: "\(item.setReps.reduce(0, +)) REPS TOTAL",
                    size: 9,
                    color: Theme.text3,
                    tracking: 0.3
                )
            }
            .padding(.bottom, 6)

            ForEach(item.setReps.indices, id: \.self) { setIndex in
                MonoLabel(
                    text: "SET \(setIndex + 1) \u{00B7} \(item.setReps[setIndex]) REPS",
                    size: 9,
                    color: Theme.text3,
                    tracking: 0.3
                )
                .padding(.bottom, 2)
            }

            if !isLast {
                Rectangle()
                    .fill(Theme.border)
                    .frame(height: 1)
                    .padding(.vertical, 13)
            }
        }
    }
}

#Preview("Session Detail") {
    let session = Session()
    session.workoutName = "Full Body"
    session.durationSeconds = 1450
    session.caloriesBurned = 102
    session.date = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 1))!

    let item1 = SessionItem()
    item1.order = 0
    item1.exerciseName = "Push-Ups"
    item1.plannedSets = 3
    item1.plannedReps = 12
    item1.setReps = [12, 12, 12]

    let item2 = SessionItem()
    item2.order = 1
    item2.exerciseName = "Pull-Ups"
    item2.plannedSets = 3
    item2.plannedReps = 8
    item2.setReps = [8, 8, 8]

    session.items = [item1, item2]

    return SessionDetailView(session: session)
        .preferredColorScheme(.dark)
}
