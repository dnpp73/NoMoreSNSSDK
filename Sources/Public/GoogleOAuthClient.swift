import Foundation
import OAuthSwift

public class GoogleOAuthClient: AbstractOAuthClient {

    public let scope: String

    public var client: OAuthSwiftClient { oauth2Swift.client }

    private let authorizeURLString = "https://accounts.google.com/o/oauth2/auth"
    private let accessTokenURLString = "https://accounts.google.com/o/oauth2/token"
    private let responseType = "code"

    private var oauth2Swift: OAuth2Swift {
        guard let oauth2Swift = oauthSwift as? OAuth2Swift else {
            fatalError("must not here")
        }
        return oauth2Swift
    }

    public init(consumerKey: String, consumerSecret: String, scope: String, callbackURL: URL) {
        self.scope = scope
        let oauthSwift = OAuth2Swift(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            authorizeUrl: authorizeURLString,
            accessTokenUrl: accessTokenURLString,
            responseType: responseType
        )
        oauthSwift.allowMissingStateCheck = true
        super.init(oauthSwift: oauthSwift, callbackURL: callbackURL)
    }

    public convenience init(consumerKey: String, consumerSecret: String, oauthToken: String, scope: String, callbackURL: URL) {
        self.init(consumerKey: consumerKey, consumerSecret: consumerSecret, scope: scope, callbackURL: callbackURL)
        oauthSwift.client.credential.oauthToken = oauthToken
    }

    public func login(completion: @escaping (Result<GoogleOAuthClient, OAuthSwiftError>) -> Void) {
        oauthSwift.authorizeURLHandler = createURLHandlerWebViewController()
        _ = oauth2Swift.authorize(withCallbackURL: callbackURL, scope: scope, state: "") { result in
            switch result {
            case .success(_):
                completion(.success(self))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
