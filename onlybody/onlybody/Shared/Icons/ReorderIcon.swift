import SwiftUI

struct ReorderIcon: View {
    var body: some View {
        Canvas { context, size in
            context.scaleBy(x: size.width / AppIcons.viewport, y: size.width / AppIcons.viewport)
            for x in [9, 15] {
                for y in [6, 12, 18] {
                    context.fill(Path(ellipseIn: CGRect(x: x - 1, y: y - 1, width: 2, height: 2)), with: .color(Theme.text2))
                }
            }
        }.frame(width: Theme.type20, height: Theme.type20)
    }
}
