import UIKit
import WebKit
import OAuthSwift

final class WebViewController: OAuthWebViewController {

    // OAuth Callback URL の指定と同じ URL にすることで URL Scheme の設定をすることなく処理をこちらで握ることが出来る。
    var callbackURL: URL?
    weak var callbackURLHandler: OAuthClientCallbackURLHandler?
    private var targetURL: URL?
    private var observer: NSKeyValueObservation?
    private var webView: WKWebView?

    deinit {
        observer?.invalidate()
    }

    override var title: String? {
        didSet {
            navigationController?.title = title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = WKWebViewConfiguration()
        configuration.allowsAirPlayForMediaPlayback = false
        configuration.allowsInlineMediaPlayback = false
        configuration.allowsPictureInPictureMediaPlayback = false
        let webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.navigationDelegate = self

        webView.allowsLinkPreview = false
        webView.allowsBackForwardNavigationGestures = false

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

        view.addSubview(webView)
        webView.addConstraintsToSuperviewEdges()
        self.webView = webView

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleActionCancelBarButtonItem(_:)))
    }

    override func doHandle(_ url: URL) {
        // nop.
        // WebViewNavigationController の方で present する実装にするので事故回避のため空実装で override.
    }

    override func handle(_ url: URL) {
        // don't need call super method.
        targetURL = url
        if let url = targetURL, let webView = webView {
            DispatchQueue.main.async {
                webView.load(URLRequest(url: url))
            }
        }
    }

    override func dismissWebViewController() {
        // don't need call super method.
        let completion: () -> Void = { [unowned self] in
            self.delegate?.oauthWebViewControllerDidDismiss()
        }
        navigationController?.dismiss(animated: dismissViewControllerAnimated, completion: completion)
    }

    @objc
    private func handleActionCancelBarButtonItem(_ sender: UIBarButtonItem) {
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

extension UIView {
    fileprivate func addConstraintsToEdges(_ targetView: UIView) {
        // 制約を満たせるような View 階層になってないと実行時に落ちる (AutoLayout の仕様) ため、使うときは注意。
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: targetView.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: targetView.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: targetView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: targetView.bottomAnchor).isActive = true
    }

    fileprivate func addConstraintsToSuperviewEdges() {
        // こちらは上のメソッドと違い、常に superview を見ているため安全に叩ける。
        guard let superview = superview else {
            return
        }
        addConstraintsToEdges(superview)
    }
}
