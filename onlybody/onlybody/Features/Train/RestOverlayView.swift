import SwiftUI

struct RestOverlayView: View {
    let remainingString: String
    let nextExerciseName: String
    let onSkip: () -> Void
    var setLabel = ""

    var body: some View {
        VStack(spacing: Theme.sectionGap) {
            Spacer()
            Text(.uiRecovery).font(Theme.fontSans(Theme.typeHeading, .bold)).foregroundStyle(Theme.text)
            Text(remainingString).font(Theme.fontMono(Theme.typeTimer, .medium)).foregroundStyle(Theme.accent)
                .accessibilityIdentifier("rest.timer")
            VStack(spacing: Theme.space12) {
                Text(setLabel).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                Text(nextExerciseName).font(Theme.fontSans(Theme.typeExercise, .bold)).foregroundStyle(Theme.text)
            }.padding(Theme.cardInset).frame(maxWidth: .infinity)
                .background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
            Spacer()
        }
        .padding(Theme.horizontalPadding).frame(maxWidth: .infinity, maxHeight: .infinity).background(Theme.bg.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: String(localized: .uiSkipRest), action: onSkip)
                .accessibilityIdentifier("rest.skip").padding(Theme.cardInset).background(Theme.bg)
        }
        .accessibilityAddTraits(.isModal)
    }
}
