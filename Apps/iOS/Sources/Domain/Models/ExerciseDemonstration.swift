import Foundation

/// Curated video metadata, independent of generated exercise UUIDs and persistence.
nonisolated struct ExerciseDemonstration: Sendable, Equatable, Identifiable {
    let id: String
    let exerciseName: String
    let videoID: String
    let author: String
    let startSeconds: Int

    var watchURL: URL? {
        guard isValid else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(videoID)&t=\(startSeconds)s")
    }

    var isValid: Bool {
        let allowed = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_")
        return videoID.count == 11 && videoID.allSatisfy { allowed.contains($0) }
            && startSeconds >= 0 && !id.isEmpty && !exerciseName.isEmpty && !author.isEmpty
    }
}
