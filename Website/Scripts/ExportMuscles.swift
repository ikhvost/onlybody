import AppKit
import SwiftUI

/// Exports the application's own renderer and catalog roles for the static website.
@main
struct ExportMuscles {
    @MainActor static func main() throws {
        let root = URL(filePath: CommandLine.arguments[1])
        let output = root.appending(path: "Website/dist/assets/muscles")
        let asset = root.appending(path: "onlybody/onlybody/Resources/Assets.xcassets/MuscleAnatomy.imageset/muscle-anatomy.png")
        guard let bitmap = NSImage(contentsOf: asset) else { throw CocoaError(.fileReadCorruptFile) }
        let examples: [(String, String, String)] = [
            ("Scripts/StoreGenerator/SeedData.json", "Standard Push-Ups", "push-ups"),
            ("Scripts/StoreGenerator/SeedData.json", "Squats", "squats"),
            ("Scripts/StoreGenerator/SeedData.json", "Chin-Ups", "chin-ups"),
            ("Scripts/StoreGenerator/OnlyWeights/SeedData.json", "Barbell Bench Press", "bench-press"),
            ("Scripts/StoreGenerator/OnlyWeights/SeedData.json", "Lat Pulldown", "lat-pulldown"),
            ("Scripts/StoreGenerator/OnlyWeights/SeedData.json", "Barbell Back Squat", "back-squat")
        ]
        for (catalog, name, slug) in examples {
            let data = try Data(contentsOf: root.appending(path: catalog))
            guard let exercises = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                  let exercise = exercises.first(where: { $0["name"] as? String == name }),
                  let primary = exercise["primaryMuscles"] as? [String],
                  let secondary = exercise["secondaryMuscles"] as? [String] else {
                throw CocoaError(.fileReadCorruptFile)
            }
            let view = MuscleAnatomyView(
                diagram: MuscleDiagram(primaryMuscles: primary, secondaryMuscles: secondary),
                image: Image(nsImage: bitmap)
            ).frame(width: 900, height: 900)
            let renderer = ImageRenderer(content: view)
            guard let image = renderer.cgImage,
                  let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
                throw CocoaError(.fileWriteUnknown)
            }
            try png.write(to: output.appending(path: "\(slug).png"))
        }
    }
}
