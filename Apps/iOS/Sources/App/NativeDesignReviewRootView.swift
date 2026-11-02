#if DEBUG
import SwiftUI

/// An explicitly opted-in, preview-only gallery for native visual QA; excluded from Release.
struct NativeDesignReviewRootView: View {
    static var isEnabled: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["ONLYBODY_DESIGN_REVIEW"] == "1"
            && environment["ONLYBODY_UI_STORE"].flatMap(UUID.init(uuidString:)) != nil
    }
    @State private var fixture: NativeDesignReviewFixture?
    @State private var index = 0

    var body: some View {
        VStack(spacing: Theme.space0) {
            if let fixture {
                fixture.screen(index).id(index).frame(maxWidth: .infinity, maxHeight: .infinity)
                if [0, 1, 12, 14].contains(index) {
                    BottomNav(selectedTab: index == 12 ? .log : index == 14 ? .library : .train, setTab: { _ in })
                }
                HStack {
                    Text(String(index)).accessibilityIdentifier("designReview.index")
                    Spacer()
                    Button("Next") { index = (index + 1) % 20 }.accessibilityIdentifier("designReview.next")
                }.frame(height: Theme.touchSize).padding(.horizontal, Theme.horizontalPadding)
            } else {
                ProgressView().tint(Theme.accent)
            }
        }
        .font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text).background(Theme.bg).preferredColorScheme(.dark)
        .task { fixture = await NativeDesignReviewFixture() }
        .onDisappear { fixture?.active.cleanup() }
    }
}
#endif
