import SwiftUI

struct LogRow: View {
    let viewModel: LogViewModel
    let session: SessionSnapshot

    var body: some View {
        HStack(spacing: Theme.space10) {
            LogDateSquare(viewModel: viewModel, session: session)

            VStack(alignment: .leading, spacing: Theme.space3) {
                Text(session.workoutName)
                    .font(Theme.fontSans(Theme.typeCard, .bold))
                    .foregroundStyle(Theme.text)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: Theme.space6) {
                    Text(viewModel.weekdayText(for: session))
                    Text("·")
                    Text(viewModel.durationText(for: session))
                }
                .font(Theme.fontMono(Theme.typeMeta))
                .foregroundStyle(Theme.text2)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            ChevronIcon(color: Theme.text3)
        }
        .padding(.vertical, Theme.space9)
        .padding(.horizontal, Theme.horizontalPadding)
        .contentShape(.rect)
    }
}
