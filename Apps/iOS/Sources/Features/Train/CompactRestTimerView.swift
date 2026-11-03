import SwiftUI

struct CompactRestTimerView: View {
    let viewModel: ActiveWorkoutViewModel

    var body: some View {
        if viewModel.isRestActive {
            HStack(spacing: Theme.space8) {
                VStack(alignment: .leading, spacing: Theme.space2) {
                    Text(.uiRest).font(Theme.fontSans(Theme.type13)).foregroundStyle(Theme.text2)
                    Text(Duration.seconds(viewModel.remainingRestSeconds), format: .time(pattern: .minuteSecond(padMinuteToLength: 2)))
                        .font(Theme.fontMono(Theme.type24, .medium)).foregroundStyle(Theme.accent)
                        .accessibilityIdentifier("rest.remaining")
                }
                Spacer(minLength: Theme.space0)
                Button("+" + String(localized: .uiSecondsCount(15))) { viewModel.extendRest() }
                    .frame(minWidth: Theme.touchSize, minHeight: Theme.touchSize)
                    .padding(.horizontal, Theme.space12).background(Theme.glassTint, in: .capsule)
                    .accessibilityIdentifier("rest.add")
                Button(String(localized: .uiSkipRest)) { viewModel.skipRest() }
                    .frame(minWidth: Theme.touchSize, minHeight: Theme.touchSize)
                    .padding(.horizontal, Theme.space12).background(Theme.glassTint, in: .capsule)
                    .accessibilityIdentifier("rest.skip")
            }
            .font(Theme.fontSans(Theme.typeMeta))
            .buttonStyle(.plain)
            .frame(minHeight: Theme.completeHeight)
            .padding(.horizontal, Theme.horizontalPadding)
            .modifier(GlassSurface(shape: RoundedRectangle(cornerRadius: Theme.cornerRadius)))
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.vertical, Theme.space8)
        }
    }
}
