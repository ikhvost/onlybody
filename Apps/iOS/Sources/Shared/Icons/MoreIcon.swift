import SwiftUI

struct MoreIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = Theme.type24

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)
            for x in [6.0, 12.0, 18.0] {
                context.fill(Path(ellipseIn: CGRect(x: x - 1.5, y: 10.5, width: 3, height: 3)), with: .color(color))
            }
        }
        .frame(width: size, height: size)
    }
}
