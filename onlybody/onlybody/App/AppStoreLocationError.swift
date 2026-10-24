/// Invalid UI-test settings must not accidentally open the normal data store.
enum AppStoreLocationError: Error {
    case invalidTestConfiguration
}
