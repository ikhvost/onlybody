import SwiftUI

struct LogView: View {
    let viewModel: LogViewModel
    let showSessionDetail: (UUID) -> Void

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .tint(Theme.accent)
            } else if let errorMessage = viewModel.errorMessage, viewModel.sessions.isEmpty {
                VStack(spacing: 10) {
                     MonoLabel(text: errorMessage, size: 11, color: Theme.text2, tracking: 0.4)
                     Button("Retry") {
                         Task { await viewModel.load() }
                     }
                     .font(Theme.fontMono(13, .medium))
                    .foregroundStyle(Theme.accent)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerView

                        if viewModel.sessions.isEmpty {
                            emptyState
                        } else {
                            sessionList
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .task { await viewModel.load() }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            MonoLabel(text: "Training history", size: 10, color: Theme.text3, tracking: 1.2)
            Text("Log")
                .font(Theme.fontSans(28, .heavy))
                .tracking(-1)
                .foregroundStyle(Theme.text)
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, 16)
        .padding(.bottom, 14)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Spacer().frame(height: 120)
            MonoLabel(text: "No training history yet", size: 11, color: Theme.text2, tracking: 0.4)
        }
        .frame(maxWidth: .infinity)
    }

    private var sessionList: some View {
        ForEach(viewModel.monthSections, id: \.label) { section in
            monthHeader(label: section.label)

            ForEach(section.sessions, id: \.id) { session in
                Button {
                    showSessionDetail(session.id)
                } label: {
                    sessionRow(for: session)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(session.workoutName), \(viewModel.weekdayText(for: session))")
            }
        }
    }

    private func monthHeader(label: String) -> some View {
        MonoLabel(text: label, size: 11, color: Theme.text3, tracking: 1.0)
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, 14)
            .padding(.bottom, 8)
    }

    private func sessionRow(for session: Session) -> some View {
        HStack(spacing: 10) {
            dateSquare(for: session)

            VStack(alignment: .leading, spacing: 3) {
                Text(session.workoutName)
                    .font(Theme.fontSans(15, .bold))
                    .foregroundStyle(Theme.text)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(viewModel.weekdayText(for: session))
                    Text("·")
                    Text(viewModel.durationText(for: session))
                }
                .font(Theme.fontMono(10))
                .foregroundStyle(Theme.text2)
                .lineLimit(1)
            }

            Spacer()

            ChevronIcon(color: Theme.text3)
        }
        .padding(.vertical, 9)
        .padding(.horizontal, Theme.horizontalPadding)
    }

    private func dateSquare(for session: Session) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Theme.surface)
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.border2, lineWidth: 1)
            Text(viewModel.dayText(for: session))
                .font(Theme.fontMono(16, .medium))
                .foregroundStyle(Theme.text)
        }
        .frame(width: 38, height: 38)
    }
}

#Preview("Log — empty") {
    LogView(
        viewModel: LogViewModel(
            sessions: PreviewSessionRepository()
        ),
        showSessionDetail: { _ in }
    )
    .preferredColorScheme(.dark)
}

#Preview("Log — filled") {
    LogView(
        viewModel: {
            let may1 = Session()
            may1.id = UUID()
            may1.workoutName = "Full Body"
            may1.durationSeconds = 1450

            may1.date = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 1))!

            let april25 = Session()
            april25.id = UUID()
            april25.workoutName = "Upper Body"
            april25.durationSeconds = 2178

            april25.date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 25))!

            let april20 = Session()
            april20.id = UUID()
            april20.workoutName = "Lower Body"
            april20.durationSeconds = 1800

            april20.date = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 20))!

            let vm = LogViewModel(sessions: PreviewSessionRepository(sessions: [may1, april25, april20]))
            Task { await vm.load() }
            return vm
        }(),
        showSessionDetail: { _ in }
    )
    .preferredColorScheme(.dark)
}
