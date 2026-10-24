import SwiftUI

struct LogRow: View {
    let viewModel: LogViewModel
    let session: SessionSnapshot

    var body: some View {
        HStack(spacing: Theme.space10) {
            LogDateSquare(viewModel: viewModel, session: session)

            VStack(alignment: .leading, spacing: Theme.space3) {
                Text(session.workoutName)
                    .font(Theme.fontSans(Theme.type15, .bold))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)

                HStack(spacing: Theme.space6) {
                    Text(viewModel.weekdayText(for: session))
                    Text("·")
                    Text(viewModel.durationText(for: session))
                }
                .font(Theme.fontMono(Theme.type10))
                .foregroundStyle(Theme.text2)
                .lineLimit(1)
            }

            Spacer()

            ChevronIcon(color: Theme.text3)
        }
        .padding(.vertical, Theme.space9)
        .padding(.horizontal, Theme.horizontalPadding)
        .contentShape(.rect)
    }
}
