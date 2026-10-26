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
                BottomNavButton(isSelected: selectedTab == .train, action: { setTab(.train) }, label: String(localized: .uiTrainUppercase), icon: {
                    TrainIcon(color: selectedTab == .train ? Theme.accent : Theme.iconDim, size: Theme.type19)
                })
                .accessibilityLabel(String(localized: .uiTrainTab))
                .accessibilityIdentifier("tab.train")

                BottomNavButton(isSelected: selectedTab == .log, action: { setTab(.log) }, label: String(localized: .uiLogUppercase), icon: {
                    LogIcon(color: selectedTab == .log ? Theme.accent : Theme.iconDim, size: Theme.type19)
                })
                .accessibilityLabel(String(localized: .uiLogTab))
                .accessibilityIdentifier("tab.log")

                BottomNavButton(isSelected: selectedTab == .library, action: { setTab(.library) }, label: String(localized: .uiLibraryUppercase), icon: {
                    LibraryIcon(color: selectedTab == .library ? Theme.accent : Theme.iconDim, size: Theme.type19)
                })
                .accessibilityLabel(String(localized: .uiLibraryTab))
                .accessibilityIdentifier("tab.library")
            }
            .padding(.vertical, Theme.space10)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: selectedTab)
        }
        .background(Theme.bg)
        .sensoryFeedback(.impact(weight: .light), trigger: selectedTab)
    }

}
