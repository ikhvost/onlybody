import SwiftUI

struct AppTabView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let composition: AppComposition
    @State private var selectedTab: AppTab = .train
    @State private var trainPath: [TrainRoute] = []
    @State private var logPath: [UUID] = []
    @State private var libraryPath: [UUID] = []
    @State private var historyRevision = 0
    @State private var pageWidth: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isSettling = false

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
                    .modifier(TabVisibility(tab: .train, selectedTab: selectedTab, width: pageWidth, drag: dragOffset))
                LogRootView(viewModel: composition.log(), path: $logPath, revision: historyRevision)
                    .modifier(TabVisibility(tab: .log, selectedTab: selectedTab, width: pageWidth, drag: dragOffset))
                LibraryRootView(composition: composition, path: $libraryPath)
                    .modifier(TabVisibility(tab: .library, selectedTab: selectedTab, width: pageWidth, drag: dragOffset))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
                pageWidth = width
                dragOffset = 0
            }
            .background(TabSwipeBridge(
                isEnabled: showsBottomNav && !isSettling,
                onDrag: updateDrag,
                onEnd: finishDrag
            ).allowsHitTesting(false))
            if showsBottomNav {
                BottomNav(selectedTab: selectedTab, setTab: settle(on:))
            }
        }
        .background(Theme.bg)
        .preferredColorScheme(.dark)
    }

    private func updateDrag(_ distance: CGFloat) {
        guard pageWidth > 0 else { return }
        let hasNeighbor = selectedTab.adjacent(forward: distance < 0) != nil
        dragOffset = hasNeighbor ? min(pageWidth, max(-pageWidth, distance)) : 0
    }

    private func finishDrag(_ forward: Bool?) {
        let destination = forward.flatMap { selectedTab.adjacent(forward: $0) } ?? selectedTab
        settle(on: destination)
    }

    private func settle(on tab: AppTab) {
        guard !isSettling else { return }
        isSettling = true
        withAnimation(reduceMotion ? nil : .smooth(duration: Theme.tabTransitionDuration)) {
            selectedTab = tab
            dragOffset = 0
        } completion: {
            isSettling = false
        }
    }
}
