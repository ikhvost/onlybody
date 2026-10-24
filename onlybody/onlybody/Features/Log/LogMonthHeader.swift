import SwiftUI

struct LogMonthHeader: View {
    let label: String

    var body: some View {
        MonoLabel(text: label, size: Theme.type11, color: Theme.text3, tracking: 1.0)
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.top, Theme.space14)
            .padding(.bottom, Theme.space8)
    }
}
