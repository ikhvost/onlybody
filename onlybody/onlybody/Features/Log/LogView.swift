import SwiftUI

struct LogView: View {
    let viewModel: LogViewModel
    let showSessionDetail: (UUID) -> Void

    private var contentState: String {
        if viewModel.isLoading { return "loading" }
        if viewModel.errorMessage != nil && viewModel.sessions.isEmpty { return "error" }
        return "content"
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .tint(Theme.accent)
                    .transition(.opacity)
            } else if let errorMessage = viewModel.errorMessage, viewModel.sessions.isEmpty {
                VStack(spacing: Theme.space10) {
                    MonoLabel(text: errorMessage, size: Theme.type11, color: Theme.text2, tracking: 0.4)
                    Button(String(localized: .uiRetry)) {
                        Task { await viewModel.load() }
                    }
                    .font(Theme.fontMono(Theme.type13, .medium))
                    .foregroundStyle(Theme.accent)
                    .buttonStyle(PressableButtonStyle())
                }
                .transition(.opacity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.space0) {
                        LogHeader()
                        LogActivityView(viewModel: viewModel)

                        if viewModel.sessions.isEmpty {
                            LogEmpty()
                        } else {
                            LogList(viewModel: viewModel, showSessionDetail: showSessionDetail)
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: contentState)
        .task { await viewModel.load() }
    }

}

#if DEBUG
#Preview("Log — empty") {
    LogView(
        viewModel: LogViewModel(
            sessions: PreviewSessionRepository()
        ),
        showSessionDetail: { _ in }
    )
    .preferredColorScheme(.dark)
}
#endif

#if DEBUG
#Preview("Log — filled") {
    LogView(
        viewModel: {
            var may1 = SessionSnapshot()
            may1.id = UUID()
            may1.workoutName = "Full Body"
            may1.durationSeconds = 1450

            may1.date = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 1)) ?? .now

            var april25 = SessionSnapshot()
            april25.id = UUID()
            april25.workoutName = "Upper Body"
            april25.durationSeconds = 2178

            april25.date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 25)) ?? .now

            var april20 = SessionSnapshot()
            april20.id = UUID()
            april20.workoutName = "Lower Body"
            april20.durationSeconds = 1800

            april20.date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 20)) ?? .now

            let vm = LogViewModel(sessions: PreviewSessionRepository(sessions: [may1, april25, april20]))
            Task { await vm.load() }
            return vm
        }(),
        showSessionDetail: { _ in }
    )
    .preferredColorScheme(.dark)
}
#endif
