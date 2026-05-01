import SwiftUI

struct SearchIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = 20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)
            context.stroke(Path(ellipseIn: CGRect(x: 4, y: 4, width: 13, height: 13)), with: .color(color), style: AppIcons.stroke)

            var handle = Path()
            handle.move(to: CGPoint(x: 15.5, y: 15.5))
            handle.addLine(to: CGPoint(x: 20, y: 20))
            context.stroke(handle, with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
