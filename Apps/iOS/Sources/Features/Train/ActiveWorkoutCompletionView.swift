import SwiftUI

struct ActiveWorkoutCompletionView: View {
    let elapsedString: String
    let completedSets: Int
    let saveState: SessionSaveState
    let onRetry: () -> Void
    let errorMessage: String?
    let onEnd: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.sectionGap) {
                Text(.uiSessionComplete).font(Theme.fontSans(Theme.typeHeading, .bold))
                Text(elapsedString).font(Theme.fontMono(Theme.typeTimer)).foregroundStyle(Theme.accent)
                Text(.uiDesignCompletedSets).font(Theme.fontSans(Theme.typeBody))
                Text(completedSets, format: .number).font(Theme.fontMono(Theme.typeNumber))
                    .accessibilityIdentifier("completion.sets")
                Text(status).font(Theme.fontSans(Theme.typeBody)).foregroundStyle(saveState == .failed ? Theme.danger : Theme.text2)
                    .accessibilityIdentifier("completion.status")
            }.padding(Theme.horizontalPadding)
        }.scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: Theme.space12) {
                if saveState == .failed {
                    PrimaryButton(title: String(localized: .uiRetrySave), action: onRetry)
                        .accessibilityIdentifier("completion.retry")
                } else {
                    PrimaryButton(title: String(localized: .uiClose), action: onEnd,
                                  disabled: saveState != .saved && saveState != .noCompletedSets)
                        .accessibilityIdentifier("active.close")
                }
            }.padding(Theme.cardInset).background(Theme.bg)
        }
        .foregroundStyle(Theme.text).background(Theme.bg)
    }

    private var status: String {
        switch saveState {
        case .saved: String(localized: .uiDesignSaved)
        case .failed: errorMessage ?? String(localized: .uiCouldNotSaveSession)
        case .noCompletedSets: String(localized: .uiDesignNoSets)
        case .idle, .saving: String(localized: .uiDesignSaving)
        }
    }
}
