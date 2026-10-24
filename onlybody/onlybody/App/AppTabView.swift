import SwiftUI

struct AppTabView: View {
    let composition: AppComposition
    @State private var selectedTab: AppTab = .train
    @State private var trainPath: [TrainRoute] = []
    @State private var logPath: [UUID] = []
    @State private var libraryPath: [UUID] = []
    @State private var historyRevision = 0

    private var showsBottomNav: Bool {
        switch selectedTab {
        case .train: trainPath.isEmpty
        case .log: logPath.isEmpty
        case .library: libraryPath.isEmpty
        }
    }

    var body: some View {
        VStack(spacing: Theme.space0) {
            ZStack {
                TrainRootView(composition: composition, path: $trainPath, onSessionSaved: { historyRevision += 1 })
                    .modifier(TabVisibility(isSelected: selectedTab == .train))
                LogRootView(viewModel: composition.log(), path: $logPath, revision: historyRevision)
                    .modifier(TabVisibility(isSelected: selectedTab == .log))
                LibraryRootView(composition: composition, path: $libraryPath)
                    .modifier(TabVisibility(isSelected: selectedTab == .library))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if showsBottomNav {
                BottomNav(selectedTab: selectedTab, setTab: { selectedTab = $0 })
            }
        }
        .background(Theme.bg)
        .preferredColorScheme(.dark)
    }
}
