import SwiftUI

struct LogRootView: View {
    @State var viewModel: LogViewModel
    @Binding var path: [UUID]
    let revision: Int

    var body: some View {
        NavigationStack(path: $path) {
            LogView(viewModel: viewModel, showSessionDetail: { path.append($0) })
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: UUID.self) { id in
                    if let session = viewModel.sessions.first(where: { $0.id == id }) {
                        SessionDetailView(session: session)
                    } else {
                        MonoLabel(text: "Session unavailable", size: Theme.type10, color: Theme.text2)
                    }
                }
        }
        .task(id: revision) { await viewModel.load() }
        .onChange(of: path) { _, value in
            if value.isEmpty { Task { await viewModel.load() } }
        }
    }
}
