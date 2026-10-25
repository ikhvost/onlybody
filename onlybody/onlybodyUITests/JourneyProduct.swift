/// Exact catalog names used by the same five journeys in both applications.
enum JourneyProduct {
    #if ONLYWEIGHTS
    static let name = "OnlyWeights"
    static let exercise = "Barbell Bench Press"
    static let libraryExercise = "Lat Pulldown"
    static let hasDemonstrations = true // Debug candidates use the same offline player fixture as OnlyBody.
    #else
    static let name = "OnlyBody"
    static let exercise = "Standard Push-Ups"
    static let libraryExercise = "Bird Dog"
    static let hasDemonstrations = true
    #endif
}
