import SwiftUI
import WebKit

/// Thin platform adapter. The screen owns state and supplies all data and actions.
struct YouTubePlayerView: UIViewRepresentable {
    let document: YouTubeEmbedDocument
    let sessionID: UUID
    let pauseRevision: Int
    let isActive: Bool
    let onEvent: (DemonstrationPlayerEvent, UUID) -> Void
    let onOpenURL: (URL) -> Void

    func makeCoordinator() -> YouTubePlayerCoordinator {
        YouTubePlayerCoordinator(sessionID: sessionID, onEvent: onEvent, onOpenURL: onOpenURL)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.allowsPictureInPictureMediaPlayback = false
        configuration.websiteDataStore = .nonPersistent()
        configuration.userContentController.add(context.coordinator, name: "onlybodyPlayer")
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.loadHTMLString(document.html, baseURL: document.baseURL)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastPauseRevision != pauseRevision || (!isActive && context.coordinator.wasActive) {
            context.coordinator.lastPauseRevision = pauseRevision
            webView.evaluateJavaScript("pauseDemonstration()", completionHandler: nil)
            webView.pauseAllMediaPlayback(completionHandler: nil)
        }
        if context.coordinator.wasActive != isActive {
            context.coordinator.wasActive = isActive
            webView.setAllMediaPlaybackSuspended(!isActive, completionHandler: nil)
        }
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: YouTubePlayerCoordinator) {
        webView.pauseAllMediaPlayback(completionHandler: nil)
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "onlybodyPlayer")
        webView.loadHTMLString("", baseURL: nil)
    }
}
