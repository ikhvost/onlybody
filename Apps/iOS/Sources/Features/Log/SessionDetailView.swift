import Foundation
import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: SessionDetailViewModel

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: Theme.space0) {
                NavBarView(title: viewModel.session.workoutName) {
                    Button {
                        dismiss()
                    } label: {
                        ChevronIcon(isBack: true, color: Theme.text, size: Theme.type20)
                            .frame(width: Theme.touchSize, height: Theme.touchSize)
                            .contentShape(.rect)
                    }
                    .buttonStyle(NavigationControlStyle())
                    .accessibilityLabel(String(localized: .uiBackToLog))
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space0) {
                        MonoLabel(text: viewModel.formattedDate, size: Theme.typeMeta, color: Theme.text3, tracking: 1.0)
                            .padding(.bottom, Theme.space6)

                        HStack(spacing: Theme.space10) {
                            HStack(spacing: Theme.space3) {
                                Text(Duration.seconds(viewModel.session.durationSeconds).formatted(.time(pattern: .minuteSecond)))
                                    .font(Theme.fontMono(Theme.type24, .medium))
                                    .foregroundStyle(Theme.accent)
                                Text(.uiMin)
                                    .font(Theme.fontMono(Theme.typeMeta))
                                    .foregroundStyle(Theme.text2)
                            }

                        }
                        .padding(.bottom, Theme.space24)

                        Rectangle()
                            .fill(Theme.border)
                            .frame(height: 1)
                            .padding(.bottom, Theme.space16)

                        ForEach(viewModel.items.enumerated(), id: \.element.id) { index, item in
                            SessionItemRow(
                                item: item,
                                isLast: index == viewModel.items.count - 1, weightText: viewModel.weightText
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
        .background(BackSwipeBridge().allowsHitTesting(false))
        .toolbar(.hidden, for: .navigationBar)
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

    return SessionDetailView(viewModel: SessionDetailViewModel(session: session))
        .preferredColorScheme(.dark)
}
#endif
