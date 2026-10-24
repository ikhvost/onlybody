import SwiftUI

struct LogList: View {
    let viewModel: LogViewModel
    let showSessionDetail: (UUID) -> Void

    var body: some View {
        ForEach(viewModel.monthSections, id: \.label) { section in
            LogMonthHeader(label: section.label)

            ForEach(section.sessions, id: \.id) { session in
                Button {
                    showSessionDetail(session.id)
                } label: {
                    LogRow(viewModel: viewModel, session: session)
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("\(session.workoutName), \(viewModel.weekdayText(for: session))")
                .accessibilityIdentifier("session.row")
            }
        }
    }
}
