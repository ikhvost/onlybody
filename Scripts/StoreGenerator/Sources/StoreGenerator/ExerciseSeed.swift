import Foundation

struct ExerciseSeed: Decodable {
    let name: String
    let primaryMuscle: String
    let secondaryMuscles: [String]
    let equipment: [String]
    let frequencyPreference: String
}
