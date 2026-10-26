import SwiftUI

struct LogEmpty: View {

    var body: some View {
        VStack(spacing: Theme.space8) {
            Spacer().frame(height: 120)
            MonoLabel(text: String(localized: .uiNoTrainingHistoryYet), size: Theme.type11, color: Theme.text2, tracking: 0.4)
        }
        .frame(maxWidth: .infinity)
    }
}
