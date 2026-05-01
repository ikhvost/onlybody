import SwiftUI

struct DragIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = 20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)
            let dotSize: CGFloat = 2.5
            let positions: [(x: CGFloat, y: CGFloat)] = [
                (7, 5), (7, 11), (7, 17),
                (14.5, 5), (14.5, 11), (14.5, 17)
            ]

            for position in positions {
                context.fill(
                    Path(roundedRect: CGRect(x: position.x, y: position.y, width: dotSize, height: dotSize), cornerRadius: 0.5),
                    with: .color(color)
                )
            }
        }
        .frame(width: size, height: size)
    }
}
