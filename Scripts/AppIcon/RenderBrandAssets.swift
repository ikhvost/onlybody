import AppKit
import CoreText
import SwiftUI

/// Run through generate.sh to render the production SwiftUI mark without raster editing.
@main
struct RenderBrandAssets {
    @MainActor
    static func main() throws {
        let root = URL(filePath: FileManager.default.currentDirectoryPath)
        let resources = root.appending(path: "onlybody/onlybody/Resources")
        let font = resources.appending(path: "Fonts/DMSans-Variable.ttf")
        guard CTFontManagerRegisterFontsForURL(font as CFURL, .process, nil) else {
            fatalError("Could not register the bundled DM Sans font")
        }
        let product = CommandLine.arguments.dropFirst().first ?? "OnlyBody"
        guard ["OnlyBody", "OnlyWeights"].contains(product) else { fatalError("Unknown product: \(product)") }
        let assets = root.appending(path: "onlybody/Products/\(product)/Resources/Assets.xcassets")
        if product == "OnlyWeights" {
            try renderBrand(OWMarkView(size: Theme.brandIconMarkSize),
                            launchMark: OWMarkView(size: Theme.brandLaunchMarkSize), assets: assets)
        } else {
            try renderBrand(OBMarkView(size: Theme.brandIconMarkSize),
                            launchMark: OBMarkView(size: Theme.brandLaunchMarkSize), assets: assets)
        }
    }

    @MainActor
    private static func renderBrand<I: View, L: View>(_ iconMark: I, launchMark: L, assets: URL) throws {
        let icon = ZStack {
            Theme.brandBackground
            iconMark
        }.frame(width: 1024, height: 1024)
        try render(icon, scale: 1, opaque: true, to: assets.appending(path: "AppIcon.appiconset/1024.png"))
        let launch = assets.appending(path: "LaunchMark.imageset")
        try FileManager.default.createDirectory(at: launch, withIntermediateDirectories: true)
        for scale in 1...3 {
            try render(launchMark, scale: CGFloat(scale), opaque: false,
                       to: launch.appending(path: "mark-\(scale)x.png"))
        }
    }

    @MainActor
    private static func render<V: View>(_ view: V, scale: CGFloat, opaque: Bool, to url: URL) throws {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        renderer.isOpaque = opaque
        guard let image = renderer.cgImage,
              let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
            fatalError("Failed to render \(url.lastPathComponent)")
        }
        try png.write(to: url)
    }
}
