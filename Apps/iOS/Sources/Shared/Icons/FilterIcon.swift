import SwiftUI

struct FilterIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = Theme.type24

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)
            var path = Path()
            for (y, x) in [(6.0, 9.0), (12.0, 16.0), (18.0, 8.0)] {
                path.move(to: CGPoint(x: 3, y: y)); path.addLine(to: CGPoint(x: x - 2, y: y))
                path.move(to: CGPoint(x: x + 2, y: y)); path.addLine(to: CGPoint(x: 21, y: y))
                path.addEllipse(in: CGRect(x: x - 2, y: y - 2, width: 4, height: 4))
            }
            context.stroke(path, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
