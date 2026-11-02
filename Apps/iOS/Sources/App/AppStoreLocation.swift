import Foundation

/// Resolves a private test store only in Debug builds; production always uses Documents.
struct AppStoreLocation {
    static func url() throws -> URL {
        #if DEBUG
        if let identifier = ProcessInfo.processInfo.environment["ONLYBODY_UI_STORE"] {
            guard let uuid = UUID(uuidString: identifier),
                  ProcessInfo.processInfo.environment["ONLYBODY_UI_FIXTURE"] == "catalog" else {
                throw AppStoreLocationError.invalidTestConfiguration
            }
            let directory = URL.documentsDirectory.appending(path: "UITests/\(uuid.uuidString)")
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            return directory.appending(path: "default.store")
        }
        #endif
        return URL.documentsDirectory.appending(path: "default.store")
    }
}
