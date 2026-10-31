import SwiftUI

struct LogHeader: View {

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.space8) {
            MonoLabel(text: String(localized: .uiTrainingHistory), size: Theme.typeMeta, color: Theme.text3, tracking: 1.2)
            Text(.uiDesignLog)
                .font(Theme.fontSans(Theme.typeHeading, .heavy))
                .tracking(-1)
                .foregroundStyle(Theme.text)
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .padding(.top, Theme.space16)
        .padding(.bottom, Theme.space14)
    }
}
