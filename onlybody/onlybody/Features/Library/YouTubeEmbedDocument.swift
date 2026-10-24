import Foundation

/// Builds only the official IFrame player, with the app identity required by YouTube.
nonisolated struct YouTubeEmbedDocument {
    let baseURL: URL
    let html: String

    init?(demonstration: ExerciseDemonstration, bundleIdentifier: String) {
        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789.-")
        let identity = bundleIdentifier.lowercased()
        guard demonstration.isValid, !identity.isEmpty,
              identity.allSatisfy({ allowed.contains($0) }),
              let baseURL = URL(string: "https://\(identity)") else { return nil }
        let configuration: [String: Any] = [
            "videoId": demonstration.videoID,
            "width": "100%",
            "height": "100%",
            "playerVars": [
                "playsinline": 1,
                "autoplay": 0,
                "controls": 1,
                "fs": 1,
                "start": demonstration.startSeconds,
                "origin": baseURL.absoluteString
            ]
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: configuration, options: [.sortedKeys]),
              let json = String(data: data, encoding: .utf8) else { return nil }
        self.baseURL = baseURL
        html = """
        <!doctype html>
        <html><head><meta charset="utf-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <meta name="referrer" content="strict-origin-when-cross-origin">
        <style>html,body,#player{margin:0;width:100%;height:100%;background:transparent}iframe{border:0}</style>
        </head><body><div id="player"></div><script>
        let player;
        function send(name, value) {
            window.webkit.messageHandlers.onlybodyPlayer.postMessage({name:name,value:value});
        }
        function pauseDemonstration() { if (player && player.pauseVideo) player.pauseVideo(); }
        function onYouTubeIframeAPIReady() {
            const config = \(json);
            config.events = {
                onReady: function() { send('ready', 0); },
                onStateChange: function(event) { send('state', event.data); },
                onError: function(event) { send('error', event.data); }
            };
            player = new YT.Player('player', config);
        }
        document.addEventListener('visibilitychange', function() {
            if (document.hidden) pauseDemonstration();
        });
        </script><script src="https://www.youtube.com/iframe_api" onerror="send('error',5)"></script>
        </body></html>
        """
    }

    #if DEBUG
    /// Network-free WebKit fixture for exercising the real player surface in UI tests.
    static var localFixture: Self? {
        guard let url = URL(string: "https://onlybody.invalid") else { return nil }
        return Self(baseURL: url, html: """
        <!doctype html><html><head>
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'">
        <style>html,body{margin:0;height:100%}body{display:grid;place-items:center}</style>
        </head><body><button onclick="this.textContent='Pause demonstration'">Play demonstration</button>
        <script>function pauseDemonstration() {}</script></body></html>
        """)
    }

    private init(baseURL: URL, html: String) {
        self.baseURL = baseURL
        self.html = html
    }
    #endif

}
