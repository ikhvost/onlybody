import SwiftUI

struct PlayIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = Theme.type20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)
            var path = Path()
            path.move(to: CGPoint(x: 8, y: 4))
            path.addLine(to: CGPoint(x: 20, y: 12))
            path.addLine(to: CGPoint(x: 8, y: 20))
            path.closeSubpath()
            context.fill(path, with: .color(color))
        }
        .frame(width: size, height: size)
        .accessibilityElement()
    }
}
