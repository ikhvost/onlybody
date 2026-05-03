import SwiftUI

struct BottomNav: View {
    let selectedTab: AppTab
    let setTab: (AppTab) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)

            HStack(spacing: 0) {
                tabButton(for: .train, label: "TRAIN") {
                    TrainIcon(color: selectedTab == .train ? Theme.accent : Theme.iconDim, size: 19)
                }
                .accessibilityLabel("Train tab")

                tabButton(for: .log, label: "LOG") {
                    LogIcon(color: selectedTab == .log ? Theme.accent : Theme.iconDim, size: 19)
                }
                .accessibilityLabel("Log tab")

                tabButton(for: .library, label: "LIBRARY") {
                    LibraryIcon(color: selectedTab == .library ? Theme.accent : Theme.iconDim, size: 19)
                }
                .accessibilityLabel("Library tab")
            }
            .padding(.vertical, 10)
            .animation(.spring(response: 0.25, dampingFraction: 0.75), value: selectedTab)
        }
        .background(Theme.bg)
        .sensoryFeedback(.impact(.light), trigger: selectedTab)
    }

    private func tabButton(for appTab: AppTab, label: String, icon: @escaping () -> some View) -> some View {
        Button {
            setTab(appTab)
        } label: {
            VStack(spacing: 6) {
                icon()

                MonoLabel(
                    text: label,
                    size: 10,
                    color: selectedTab == appTab ? Theme.accent : Theme.text3,
                    tracking: 1.2
                )

                Rectangle()
                    .fill(selectedTab == appTab ? Theme.accent : Color.clear)
                    .frame(width: 16, height: 2)
                    .clipShape(.rect(cornerRadius: 1))
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(PressableButtonStyle())
    }
}
