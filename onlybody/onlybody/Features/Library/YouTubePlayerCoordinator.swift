import WebKit

/// Translates WebKit callbacks into value events and releases handlers with the player.
@MainActor
final class YouTubePlayerCoordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    let sessionID: UUID
    let onEvent: (DemonstrationPlayerEvent, UUID) -> Void
    let onOpenURL: (URL) -> Void
    var lastPauseRevision = 0
    var wasActive = true

    init(
        sessionID: UUID,
        onEvent: @escaping (DemonstrationPlayerEvent, UUID) -> Void,
        onOpenURL: @escaping (URL) -> Void
    ) {
        self.sessionID = sessionID
        self.onEvent = onEvent
        self.onOpenURL = onOpenURL
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.frameInfo.isMainFrame, message.name == "onlybodyPlayer",
              let body = message.body as? [String: Any],
              let name = body["name"] as? String,
              let value = body["value"] as? Int else { return }
        switch name {
        case "ready": onEvent(.ready, sessionID)
        case "error": onEvent(.failed(DemonstrationFailure(playerError: value)), sessionID)
        case "state":
            if let event = DemonstrationPlayerEvent(playerState: value) { onEvent(event, sessionID) }
        default: break
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation?, withError error: any Error) {
        reportNavigationFailure(error)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation?, withError error: any Error) {
        reportNavigationFailure(error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        onEvent(.failed(.connection), sessionID)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        if navigationAction.navigationType == .linkActivated,
           navigationAction.targetFrame?.isMainFrame != false,
           let url = navigationAction.request.url {
            openExternalURL(url)
            return .cancel
        } else {
            return .allow
        }
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url { openExternalURL(url) }
        return nil
    }

    private func openExternalURL(_ url: URL) {
        guard url.scheme == "https" || url.scheme == "http" else { return }
        onOpenURL(url)
    }

    private func reportNavigationFailure(_ error: any Error) {
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        onEvent(.failed(.connection), sessionID)
    }
}
