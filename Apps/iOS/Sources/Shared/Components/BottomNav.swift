import SwiftUI

struct BottomNav: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let selectedTab: AppTab
    let setTab: (AppTab) -> Void

    var body: some View {
        VStack(spacing: Theme.space0) {
            HStack(spacing: Theme.space0) {
                BottomNavButton(isSelected: selectedTab == .train, action: { setTab(.train) }, label: String(localized: .uiDesignTrain), icon: {
                    TrainIcon(color: selectedTab == .train ? Theme.accent : Theme.iconDim, size: Theme.type24)
                })
                .accessibilityLabel(String(localized: .uiTrainTab))
                .accessibilityIdentifier("tab.train")

                BottomNavButton(isSelected: selectedTab == .log, action: { setTab(.log) }, label: String(localized: .uiDesignLog), icon: {
                    LogIcon(color: selectedTab == .log ? Theme.accent : Theme.iconDim, size: Theme.type24)
                })
                .accessibilityLabel(String(localized: .uiLogTab))
                .accessibilityIdentifier("tab.log")

                BottomNavButton(isSelected: selectedTab == .library, action: { setTab(.library) }, label: String(localized: .uiDesignExercises), icon: {
                    LibraryIcon(color: selectedTab == .library ? Theme.accent : Theme.iconDim, size: Theme.type24)
                })
                .accessibilityLabel(String(localized: .uiLibraryTab))
                .accessibilityIdentifier("tab.library")
            }
            .padding(Theme.space4)
            .animation(reduceMotion || Theme.previewReducesMaterials ? nil : .smooth(duration: Theme.tabTransitionDuration), value: selectedTab)
        }
        .modifier(GlassSurface(shape: Capsule()))
        .padding(.horizontal, Theme.space16)
        .padding(.bottom, Theme.space8)
        .sensoryFeedback(.impact(weight: .light), trigger: selectedTab)
    }

}
