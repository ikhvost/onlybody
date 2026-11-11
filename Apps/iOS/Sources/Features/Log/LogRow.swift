import SwiftUI

struct LogRow: View {
    let viewModel: LogViewModel
    let session: SessionSnapshot

    var body: some View {
        HStack(spacing: Theme.space12) {
            Text(viewModel.dayText(for: session))
                .font(Theme.fontMono(Theme.typeCard, .medium))
                .foregroundStyle(Theme.text)
                .frame(width: Theme.touchSize)

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
        .padding(Theme.cardInset)
        .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .strokeBorder(Theme.border, lineWidth: Theme.dividerThickness)
        }
        .contentShape(.rect(cornerRadius: Theme.cornerRadius))
    }
}
