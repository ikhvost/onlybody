import SwiftUI

struct BottomNav: View {
    let selectedTab: AppTab
    let setTab: (AppTab) -> Void

    var body: some View {
        VStack(spacing: Theme.space0) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)

            HStack(spacing: Theme.space0) {
                BottomNavButton(isSelected: selectedTab == .train, action: { setTab(.train) }, label: "TRAIN", icon: {
                    TrainIcon(color: selectedTab == .train ? Theme.accent : Theme.iconDim, size: Theme.type19)
                })
                .accessibilityLabel("Train tab")
                .accessibilityIdentifier("tab.train")

                BottomNavButton(isSelected: selectedTab == .log, action: { setTab(.log) }, label: "LOG", icon: {
                    LogIcon(color: selectedTab == .log ? Theme.accent : Theme.iconDim, size: Theme.type19)
                })
                .accessibilityLabel("Log tab")
                .accessibilityIdentifier("tab.log")

                BottomNavButton(isSelected: selectedTab == .library, action: { setTab(.library) }, label: "LIBRARY", icon: {
                    LibraryIcon(color: selectedTab == .library ? Theme.accent : Theme.iconDim, size: Theme.type19)
                })
                .accessibilityLabel("Library tab")
                .accessibilityIdentifier("tab.library")
            }
            .padding(.vertical, Theme.space10)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: selectedTab)
        }
        .background(Theme.bg)
        .sensoryFeedback(.impact(weight: .light), trigger: selectedTab)
    }

}
