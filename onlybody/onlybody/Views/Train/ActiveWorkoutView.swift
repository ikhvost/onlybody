import SwiftUI

struct ActiveWorkoutView: View {
    let workoutName: String
    let onEnd: () -> Void

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                NavBarView(title: workoutName) {
                    EmptyView()
                } trailing: {
                    Button {
                        onEnd()
                    } label: {
                        Text("End")
                            .font(Theme.fontMono(11, .medium))
                            .foregroundStyle(Theme.text3)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                VStack(spacing: Theme.space10) {
                    MonoLabel(text: "Active Workout", size: 10, color: Theme.text3, tracking: 1)
                    Text(workoutName)
                        .font(Theme.fontSans(26, .heavy))
                        .tracking(-1)
                        .foregroundStyle(Theme.text)
                }

                Spacer()
            }
        }
    }
}
