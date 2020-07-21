import UIKit
import NoMoreSNSSDK
import OAuthSwift

final class TwitterViewController: UITableViewController {

    @IBOutlet private var callbackURLTextField: UITextField!
    @IBOutlet private var consumerKeyTextField: UITextField!
    @IBOutlet private var consumerSecretTextField: UITextField!
    @IBOutlet private var oauthTokenTextField: UITextField!
    @IBOutlet private var oauthTokenSecretTextField: UITextField!

    @IBOutlet private var consoleTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        callbackURLTextField.text = UserDefaults.standard.string(forKey: "TwitterCallbackURLTextField")
        consumerKeyTextField.text = UserDefaults.standard.string(forKey: "TwitterConsumerKeyTextField")
        consumerSecretTextField.text = UserDefaults.standard.string(forKey: "TwitterConsumerSecretTextField")
        oauthTokenTextField.text = UserDefaults.standard.string(forKey: "TwitterOAuthTokenTextField")
        oauthTokenSecretTextField.text = UserDefaults.standard.string(forKey: "TwitterOAuthTokenSecretTextField")
    }

    private func appendConsole(_ msg: String) {
        guard let console = consoleTextView else {
            return
        }
        let str: String
        if let current = console.text {
            str = current + "\n" + msg
        } else {
            str = msg
        }
        console.text = str
    }

    @IBAction private func handleTouchUpInsideLoginButton(_ sender: UIButton) {
        guard let callbackURLString = callbackURLTextField?.text, let callbackURL = URL(string: callbackURLString) else {
            return
        }
        guard let consumerKey = consumerKeyTextField?.text else {
            return
        }
        guard let consumerSecret = consumerSecretTextField?.text else {
            return
        }

        let twitter = TwitterOAuthClient(consumerKey: consumerKey, consumerSecret: consumerSecret, callbackURL: callbackURL)
        // twitter.oauthWebViewControllerDelegate = self
        twitter.login { (result) -> Void in
            switch result {
            case .success(_):
                UserDefaults.standard.set(callbackURLString, forKey: "TwitterCallbackURLTextField")
                UserDefaults.standard.set(consumerKey, forKey: "TwitterConsumerKeyTextField")
                UserDefaults.standard.set(consumerSecret, forKey: "TwitterConsumerSecretTextField")
                UserDefaults.standard.set(twitter.oauthToken, forKey: "TwitterOAuthTokenTextField")
                UserDefaults.standard.set(twitter.oauthTokenSecret, forKey: "TwitterOAuthTokenSecretTextField")
                UserDefaults.standard.synchronize()
                self.oauthTokenTextField?.text = twitter.oauthToken
                self.oauthTokenSecretTextField?.text = twitter.oauthTokenSecret
                self.appendConsole("[SUCCESS]")
                self.appendConsole(printCredential(twitter))
            case .failure(let error):
                self.appendConsole("[ERROR]")
                self.appendConsole(debugLog(error.description))
            }
        }
    }

    @IBAction private func handleTouchUpInsideTestButton(_ sender: UIButton) {
        guard let callbackURLString = callbackURLTextField?.text, let callbackURL = URL(string: callbackURLString) else {
            return
        }
        guard let consumerKey = consumerKeyTextField?.text else {
            return
        }
        guard let consumerSecret = consumerSecretTextField?.text else {
            return
        }
        guard let oauthToken = oauthTokenTextField?.text else {
            return
        }
        guard let oauthTokenSecret = oauthTokenSecretTextField?.text else {
            return
        }

        let twitter = TwitterOAuthClient(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: oauthToken, oauthTokenSecret: oauthTokenSecret, callbackURL: callbackURL)
        appendConsole(printCredential(twitter))
        twitter.client.get("https://api.twitter.com/1.1/statuses/mentions_timeline.json", parameters: [:]) { result in
            switch result {
            case .success(let response):
                UserDefaults.standard.set(callbackURLString, forKey: "TwitterCallbackURLTextField")
                UserDefaults.standard.set(consumerKey, forKey: "TwitterConsumerKeyTextField")
                UserDefaults.standard.set(consumerSecret, forKey: "TwitterConsumerSecretTextField")
                UserDefaults.standard.set(oauthToken, forKey: "TwitterOAuthTokenTextField")
                UserDefaults.standard.set(oauthTokenSecret, forKey: "TwitterOAuthTokenSecretTextField")
                UserDefaults.standard.synchronize()
                self.appendConsole("[SUCCESS]")
                if let jsonDict = try? response.jsonObject() {
                    self.appendConsole(debugLog(String(describing: jsonDict)))
                }
            case .failure(let error):
                self.appendConsole("[ERROR]")
                self.appendConsole(debugLog(error.description))
            }
        }
    }

}

extension TwitterViewController: OAuthWebViewControllerDelegate {

    func oauthWebViewControllerDidPresent() {
        appendConsole(debugLog())
    }

    func oauthWebViewControllerDidDismiss() {
        appendConsole(debugLog())
    }

    func oauthWebViewControllerWillAppear() {
        appendConsole(debugLog())
    }

    func oauthWebViewControllerDidAppear() {
        appendConsole(debugLog())
    }

    func oauthWebViewControllerWillDisappear() {
        appendConsole(debugLog())
    }

    func oauthWebViewControllerDidDisappear() {
        appendConsole(debugLog())
    }

}
