import SwiftUI

struct CheckIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = 20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)

            var path = Path()
            path.move(to: CGPoint(x: 4, y: 12))
            path.addLine(to: CGPoint(x: 10, y: 18))
            path.addLine(to: CGPoint(x: 20, y: 8))
            context.stroke(path, with: .color(color), style: AppIcons.checkStroke)
        }
        .frame(width: size, height: size)
    }
}
