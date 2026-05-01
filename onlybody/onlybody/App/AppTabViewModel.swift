import Observation

@MainActor @Observable final class AppTabViewModel {
    var selectedTab: AppTab = .train
}
