import Foundation
import OAuthSwift

public protocol OAuthClientCallbackURLHandler: AnyObject {
    func oauthClientShouldHandleCallbackURL(handledURL: URL) -> Bool
}

public class AbstractOAuthClient {

    public weak var oauthWebViewControllerDelegate: OAuthWebViewControllerDelegate?
    public weak var callbackURLHandler: OAuthClientCallbackURLHandler?

    public let callbackURL: URL

    internal let oauthSwift: OAuthSwift

    private var oauthCredential: OAuthSwiftCredential { oauthSwift.client.credential } // shorthand
    public var consumerKey: String { oauthCredential.consumerKey }
    public var consumerSecret: String { oauthCredential.consumerSecret }
    public var oauthToken: String { oauthCredential.oauthToken }
    public var oauthTokenSecret: String { oauthCredential.oauthTokenSecret }
    public var oauthVerifier: String { oauthCredential.oauthVerifier }
    public var oauthRefreshToken: String { oauthCredential.oauthRefreshToken }
    public var isTokenExpired: Bool { oauthCredential.isTokenExpired() }
    public var oauthTokenExpiresAt: Date? { oauthCredential.oauthTokenExpiresAt }
    public var oauthShortVersion: String { oauthCredential.version.shortVersion }
    public var oauthSignatureMethod: String { oauthCredential.signatureMethod.rawValue }

    internal init(oauthSwift: OAuthSwift, callbackURL: URL) {
        self.oauthSwift = oauthSwift
        self.callbackURL = callbackURL
    }

    internal func createURLHandlerWebViewController() -> OAuthSwiftURLHandlerType {
        let controller = WebViewController()
        controller.delegate = oauthWebViewControllerDelegate
        controller.callbackURLHandler = callbackURLHandler
        controller.callbackURL = callbackURL
        let navigationController = WebViewNavigationController(rootViewController: controller)
        return navigationController
    }

}
