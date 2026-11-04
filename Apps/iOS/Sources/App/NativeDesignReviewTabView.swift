#if DEBUG
import SwiftUI

/// Uses the shipping system tab style with detached preview fixtures.
struct NativeDesignReviewTabView: View {
    let fixture: NativeDesignReviewFixture
    let index: Int

    var body: some View {
        TabView(selection: .constant(index == 12 ? AppTab.log : index == 14 ? .library : .train)) {
            Tab(String(localized: .uiDesignTrain), systemImage: "figure.strengthtraining.traditional", value: AppTab.train) {
                fixture.screen(index == 1 ? 1 : 0)
            }
            Tab(String(localized: .uiDesignLog), systemImage: "clock.arrow.circlepath", value: AppTab.log) {
                fixture.screen(12)
            }
            Tab(String(localized: .uiDesignExercises), systemImage: "books.vertical", value: AppTab.library) {
                fixture.screen(14)
            }
        }
        .tabBarMinimizeBehavior(.never)
        .tint(Theme.accent)
    }
}
#endif
