import SwiftUI

struct AppTabView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let composition: AppComposition
    @State private var selectedTab: AppTab = .train
    @State private var trainPath: [TrainRoute] = []
    @State private var logPath: [UUID] = []
    @State private var libraryPath: [UUID] = []
    @State private var historyRevision = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(String(localized: .uiDesignTrain), systemImage: "figure.strengthtraining.traditional", value: AppTab.train) {
                TrainRootView(composition: composition, path: $trainPath, onSessionSaved: { historyRevision += 1 })
                    .font(Theme.fontSans(Theme.typeBody))
                    .toolbar(trainPath.isEmpty ? .visible : .hidden, for: .tabBar)
            }
            .accessibilityIdentifier("tab.train")

            Tab(String(localized: .uiDesignLog), systemImage: "clock.arrow.circlepath", value: AppTab.log) {
                LogRootView(viewModel: composition.log(), path: $logPath, revision: historyRevision, makeDetail: composition.sessionDetail)
                    .font(Theme.fontSans(Theme.typeBody))
                    .toolbar(logPath.isEmpty ? .visible : .hidden, for: .tabBar)
            }
            .accessibilityIdentifier("tab.log")

            Tab(String(localized: .uiDesignExercises), systemImage: "books.vertical", value: AppTab.library) {
                LibraryRootView(composition: composition, path: $libraryPath)
                    .font(Theme.fontSans(Theme.typeBody))
                    .toolbar(libraryPath.isEmpty ? .visible : .hidden, for: .tabBar)
            }
            .accessibilityIdentifier("tab.library")
        }
        .tabBarMinimizeBehavior(.never)
        .tint(Theme.accent)
        .background(Theme.bg)
        .transaction { transaction in
            if reduceMotion { transaction.animation = nil; transaction.disablesAnimations = true }
        }
        .preferredColorScheme(.dark)
    }
}
