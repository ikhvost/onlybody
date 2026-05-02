import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: SessionDetailViewModel

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: viewModel.workoutName) {
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
                    VStack(alignment: .leading, spacing: 0) {
                        MonoLabel(text: viewModel.dateLabel, size: 9, color: Theme.text3, tracking: 1.0)
                            .padding(.bottom, Theme.space6)

                        HStack(spacing: Theme.space10) {
                            HStack(spacing: Theme.space3) {
                                Text(viewModel.durationValue)
                                    .font(Theme.fontMono(24, .medium))
                                    .foregroundStyle(Theme.accent)
                                Text(viewModel.durationUnit)
                                    .font(Theme.fontMono(12))
                                    .foregroundStyle(Theme.text2)
                            }

                            HStack(spacing: Theme.space3) {
                                Text(viewModel.caloriesValue)
                                    .font(Theme.fontMono(24, .medium))
                                    .foregroundStyle(Theme.text)
                                if !viewModel.caloriesUnit.isEmpty {
                                    Text(viewModel.caloriesUnit)
                                        .font(Theme.fontMono(12))
                                        .foregroundStyle(Theme.text2)
                                }
                            }
                        }
                        .padding(.bottom, Theme.space24)

                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 1)
                            .padding(.bottom, Theme.space16)

                        ForEach(viewModel.sortedItems.enumerated(), id: \.element.id) { (index, item) in
                            SessionItemRow(
                                item: item,
                                isLast: index == viewModel.sortedItems.count - 1,
                                viewModel: viewModel
                            )
                        }

                        GhostButton(
                            title: "Repeat this session",
                            action: {}
                        )
                        .padding(.top, Theme.space24)
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
}

private struct SessionItemRow: View {
    let item: SessionItem
    let isLast: Bool
    let viewModel: SessionDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(item.exerciseName)
                    .font(Theme.fontSans(14, .bold))
                    .foregroundStyle(Theme.text)

                Spacer()

                MonoLabel(
                    text: "\(viewModel.totalReps(for: item)) REPS TOTAL",
                    size: 9,
                    color: Theme.text3,
                    tracking: 0.3
                )
            }
            .padding(.bottom, Theme.space6)

            ForEach(item.setReps.indices, id: \.self) { setIndex in
                MonoLabel(
                    text: viewModel.setLabel(index: setIndex, reps: item.setReps[setIndex]),
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
                    .padding(.vertical, Theme.space13)
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

    return SessionDetailView(
        viewModel: SessionDetailViewModel(session: session)
    )
    .preferredColorScheme(.dark)
}
