import UIKit
import WebKit
import OAuthSwift

final class WebViewController: OAuthWebViewController {

    // OAuth Callback URL の指定と同じ URL にすることで URL Scheme の設定をすることなく処理をこちらで握ることが出来る。
    var callbackURL: URL?
    weak var callbackURLHandler: OAuthClientCallbackURLHandler?

    private var targetURL: URL?

    private var observer: NSKeyValueObservation?

    @IBOutlet private var customNavigationItem: UINavigationItem!

    @IBOutlet private var webView: WKWebView! {
        didSet {
            if let webView = webView {
                webView.navigationDelegate = self

                // for Google login hack
                webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0 Mobile/15E148 Safari/604.1"

                // for set Title
                observer?.invalidate()
                observer = webView.observe(\.title, options: [.new]) { (webView, change) -> Void in
                    guard let optionalTitle = change.newValue, let title = optionalTitle, !title.isEmpty else {
                        self.title = nil
                        return
                    }
                    self.title = title
                }
            }
        }
    }

    deinit {
        observer?.invalidate()
    }

    override var title: String? {
        didSet {
            customNavigationItem.title = title
        }
    }

    override func handle(_ url: URL) {
        targetURL = url
        super.handle(url)
        if let url = targetURL {
            DispatchQueue.main.async {
                let req = URLRequest(url: url)
                self.webView.load(req)
            }
        }
    }

    @IBAction private func handleActionCancelBarButtonItem(_ sender: UIBarButtonItem) {
        dismissWebViewController()
    }
}

extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // IMPORTANT: callback url hack
        // Detail: API with only HTTP scheme into callback URL
        // URL: https://github.com/OAuthSwift/OAuthSwift/wiki/API-with-only-HTTP-scheme-into-callback-URL
        if let url = navigationAction.request.url, let callbackURL = callbackURL {
            let urlString = url.absoluteString
            let redirectUri = callbackURL.absoluteURL
            if let _ = urlString.range(of: "\(redirectUri)?") {
                if let callbackURLHandler = callbackURLHandler {
                    let shouldHandle = callbackURLHandler.oauthClientShouldHandleCallbackURL(handledURL: url)
                    if shouldHandle {
                        OAuthSwift.handle(url: url)
                    }
                } else {
                    // Default: Handle URL
                    OAuthSwift.handle(url: url)
                }
                decisionHandler(.cancel)
                dismissWebViewController()
                return
            }
        }
        decisionHandler(.allow)
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        dismissWebViewController()
    }

}
