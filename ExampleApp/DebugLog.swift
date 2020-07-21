import Foundation
import NoMoreSNSSDK
import OAuthSwift

@discardableResult
func debugLog(fileName: String = #file, line: Int = #line, functionName: String = #function, _ msg: String = "") -> String {
    let string = "\(Date().description) [\(fileName.split(separator: "/").last ?? "") @L\(line) \(functionName)] " + msg
    print(string)
    return string
}

@discardableResult
func printCredential(_ client: AbstractOAuthClient) -> String {
    var string = ""
    // string.append("credential:           \(credential)\n")
    string.append("consumerKey:          \(client.consumerKey)\n")
    string.append("consumerSecret:       \(client.consumerSecret)\n")
    string.append("oauthToken:           \(client.oauthToken)\n")
    string.append("oauthTokenSecret:     \(client.oauthTokenSecret)\n")
    string.append("oauthVerifier:        \(client.oauthVerifier)\n")
    string.append("oauthRefreshToken:    \(client.oauthRefreshToken)\n")
    string.append("isTokenExpired:       \(client.isTokenExpired)\n")
    if let oauthTokenExpiresAt = client.oauthTokenExpiresAt {
        string.append("oauthTokenExpiresAt:  \(oauthTokenExpiresAt)\n")
    } else {
        string.append("oauthTokenExpiresAt: nil\n")
    }
    string.append("oauthShortVersion:    \(client.oauthShortVersion)\n")
    string.append("oauthSignatureMethod: \(client.oauthSignatureMethod)")
    print(string)
    return string
}
