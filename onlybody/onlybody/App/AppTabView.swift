import SwiftUI

struct AppTabView: View {
    @State private var tabViewModel = AppTabViewModel()
    @State private var trainPath = NavigationPath()
    @State private var logPath = NavigationPath()
    @State private var libraryPath = NavigationPath()

    private var showsBottomNav: Bool {
        switch tabViewModel.selectedTab {
        case .train:
            trainPath.isEmpty
        case .log:
            logPath.isEmpty
        case .library:
            libraryPath.isEmpty
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if showsBottomNav {
                BottomNav(
                    selectedTab: tabViewModel.selectedTab,
                    setTab: { tabViewModel.selectedTab = $0 }
                )
            }
        }
        .background(Theme.bg)
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var tabContent: some View {
        ZStack {
            tabStack(.train, path: $trainPath) {
                TrainView()
            }

            tabStack(.log, path: $logPath) {
                LogView()
            }

            tabStack(.library, path: $libraryPath) {
                LibraryView()
            }
        }
    }

    private func tabStack<Content: View>(
        _ tab: AppTab,
        path: Binding<NavigationPath>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack(path: path) {
            content()
                .toolbar(.hidden, for: .navigationBar)
        }
        .opacity(tabViewModel.selectedTab == tab ? 1 : 0)
        .allowsHitTesting(tabViewModel.selectedTab == tab)
        .accessibilityHidden(tabViewModel.selectedTab != tab)
    }
}
