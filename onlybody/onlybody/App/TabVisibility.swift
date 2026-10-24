import SwiftUI

/// Keeps each tab alive and positions neighboring screens beside the selected screen.
struct TabVisibility: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let tab: AppTab
    let selectedTab: AppTab
    let width: CGFloat
    let drag: CGFloat

    func body(content: Content) -> some View {
        content
            .offset(x: reduceMotion ? 0 : CGFloat(tab.position - selectedTab.position) * width + drag)
            .opacity(reduceMotion || width == 0 ? (tab == selectedTab ? 1 : 0) : 1)
            .allowsHitTesting(tab == selectedTab)
            .accessibilityHidden(tab != selectedTab)
    }
}
