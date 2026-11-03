import SwiftUI

struct CloseIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = Theme.type24

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)
            var path = Path()
            path.move(to: CGPoint(x: 6, y: 6)); path.addLine(to: CGPoint(x: 18, y: 18))
            path.move(to: CGPoint(x: 18, y: 6)); path.addLine(to: CGPoint(x: 6, y: 18))
            context.stroke(path, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
