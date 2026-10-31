import SwiftUI

struct AppContentView: View {
    let composition: AppComposition

    var body: some View {
        #if DEBUG
        if NativeDesignReviewRootView.isEnabled {
            NativeDesignReviewRootView()
        } else {
            AppTabView(composition: composition)
        }
        #else
        AppTabView(composition: composition)
        #endif
    }
}
