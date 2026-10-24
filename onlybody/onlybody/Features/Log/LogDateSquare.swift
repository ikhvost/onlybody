import SwiftUI

struct LogDateSquare: View {
    let viewModel: LogViewModel
    let session: SessionSnapshot

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Theme.surface)
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.border2, lineWidth: 1)
            Text(viewModel.dayText(for: session))
                .font(Theme.fontMono(Theme.type16, .medium))
                .foregroundStyle(Theme.text)
        }
        .frame(width: 38, height: 38)
    }
}
