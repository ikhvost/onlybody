import SwiftUI

struct WorkoutCreationChoice: View {
    let title: String
    let hint: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Theme.space12) {
                Text(title).font(Theme.fontSans(Theme.typeCard, .bold)).foregroundStyle(Theme.text)
                Text(hint).font(Theme.fontSans(Theme.typeBody)).foregroundStyle(Theme.text2)
            }
            .frame(maxWidth: .infinity, minHeight: Theme.buttonHeight, alignment: .leading)
            .padding(Theme.cardInset).background(Theme.surface, in: .rect(cornerRadius: Theme.cornerRadius))
            .overlay { RoundedRectangle(cornerRadius: Theme.cornerRadius).stroke(Theme.border2) }
        }.buttonStyle(PressableButtonStyle())
    }
}
