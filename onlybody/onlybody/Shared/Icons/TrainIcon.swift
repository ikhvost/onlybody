import SwiftUI

struct TrainIcon: View {
    var color: Color = Theme.text
    var size: CGFloat = Theme.type20

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / AppIcons.viewport
            context.scaleBy(x: scale, y: scale)
            context.stroke(Path(roundedRect: CGRect(x: 3, y: 4, width: 8, height: 6), cornerRadius: 1), with: .color(color), style: AppIcons.stroke)
            context.stroke(Path(roundedRect: CGRect(x: 13, y: 4, width: 8, height: 6), cornerRadius: 1), with: .color(color), style: AppIcons.stroke)
            context.stroke(Path(roundedRect: CGRect(x: 3, y: 14, width: 18, height: 6), cornerRadius: 1), with: .color(color), style: AppIcons.stroke)
        }
        .frame(width: size, height: size)
    }
}
