import SwiftUI

struct PlayIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = 20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)

            var triangle = Path()
            triangle.move(to: CGPoint(x: 6, y: 3))
            triangle.addLine(to: CGPoint(x: 20, y: 12))
            triangle.addLine(to: CGPoint(x: 6, y: 21))
            triangle.closeSubpath()
            context.fill(triangle, with: .color(color))
        }
        .frame(width: size, height: size)
    }
}
