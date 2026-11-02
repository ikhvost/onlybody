import SwiftUI

struct CheckIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = Theme.type20
    var body: some View {
        Canvas { context, canvasSize in
            context.scaleBy(x: canvasSize.width / AppIcons.viewport, y: canvasSize.width / AppIcons.viewport)
            var path = Path()
            path.move(to: CGPoint(x: 4, y: 12))
            path.addLine(to: CGPoint(x: 9, y: 17))
            path.addLine(to: CGPoint(x: 20, y: 6))
            context.stroke(path, with: .color(color), style: AppIcons.stroke)
        }.frame(width: size, height: size)
    }
}
