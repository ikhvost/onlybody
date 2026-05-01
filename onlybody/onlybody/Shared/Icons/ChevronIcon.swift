import SwiftUI

struct ChevronIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = 20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)

            var path = Path()
            path.move(to: CGPoint(x: 9, y: 4))
            path.addLine(to: CGPoint(x: 17, y: 12))
            path.addLine(to: CGPoint(x: 9, y: 20))
            context.stroke(path, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
