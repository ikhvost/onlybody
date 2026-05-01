import SwiftUI

struct PlusIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = 20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)

            var verticalLine = Path()
            verticalLine.move(to: CGPoint(x: 12, y: 4))
            verticalLine.addLine(to: CGPoint(x: 12, y: 20))
            context.stroke(verticalLine, with: .color(color), style: AppIcons.stroke)

            var horizontalLine = Path()
            horizontalLine.move(to: CGPoint(x: 4, y: 12))
            horizontalLine.addLine(to: CGPoint(x: 20, y: 12))
            context.stroke(horizontalLine, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
