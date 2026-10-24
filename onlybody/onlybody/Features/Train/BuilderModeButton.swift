import SwiftUI

struct BuilderModeButton: View {
    @Bindable var viewModel: SessionBuilderViewModel
    let label: String
    let mode: WorkoutMode

    var body: some View {
        Button {
            viewModel.mode = mode
        } label: {
            Text(label)
                .font(Theme.fontSans(Theme.type14, .semibold))
                .foregroundStyle(viewModel.mode == mode ? Theme.accentDark : Theme.text2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.space10)
                .background(viewModel.mode == mode ? Theme.accent : Theme.surface2)
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(
                            viewModel.mode == mode ? Theme.accent : Theme.border2,
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
    }
}
