import Foundation
import OAuthSwift

public class TwitterOAuthClient: AbstractOAuthClient {

    public var client: OAuthSwiftClient { oauth1Swift.client }

    private let requestTokenURLString = "https://api.twitter.com/oauth/request_token"
    private let authorizeURLString =  "https://api.twitter.com/oauth/authorize"
    private let accessTokenURLString = "https://api.twitter.com/oauth/access_token"

    private var oauth1Swift: OAuth1Swift {
        guard let oauth1Swift = oauthSwift as? OAuth1Swift else {
            fatalError("must not here")
        }
        return oauth1Swift
    }

    public init(consumerKey: String, consumerSecret: String, callbackURL: URL) {
        let oauthSwift = OAuth1Swift(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            requestTokenUrl: requestTokenURLString,
            authorizeUrl: authorizeURLString,
            accessTokenUrl: accessTokenURLString
        )
        super.init(oauthSwift: oauthSwift, callbackURL: callbackURL)
    }

    public convenience init(consumerKey: String, consumerSecret: String, oauthToken: String, oauthTokenSecret: String, callbackURL: URL) {
        self.init(consumerKey: consumerKey, consumerSecret: consumerSecret, callbackURL: callbackURL)
        oauthSwift.client.credential.oauthToken = oauthToken
        oauthSwift.client.credential.oauthTokenSecret = oauthTokenSecret
    }

    public func login(completion: @escaping (Result<TwitterOAuthClient, OAuthSwiftError>) -> Void) {
        oauthSwift.authorizeURLHandler = createURLHandlerWebViewController()
        _ = oauth1Swift.authorize(withCallbackURL: callbackURL) { result in
            switch result {
            case .success(_):
                completion(.success(self))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
