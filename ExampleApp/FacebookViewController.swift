import UIKit
import NoMoreSNSSDK
import OAuthSwift

final class FacebookViewController: UITableViewController {

    @IBOutlet private var callbackURLTextField: UITextField!
    @IBOutlet private var scopeTextField: UITextField!
    @IBOutlet private var consumerKeyTextField: UITextField!
    @IBOutlet private var consumerSecretTextField: UITextField!
    @IBOutlet private var oauthTokenTextField: UITextField!

    @IBOutlet private var consoleTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        callbackURLTextField.text = UserDefaults.standard.string(forKey: "FacebookCallbackURLTextField")
        scopeTextField.text = UserDefaults.standard.string(forKey: "FacebookScopeTextField")
        consumerKeyTextField.text = UserDefaults.standard.string(forKey: "FacebookConsumerKeyTextField")
        consumerSecretTextField.text = UserDefaults.standard.string(forKey: "FacebookConsumerSecretTextField")
        oauthTokenTextField.text = UserDefaults.standard.string(forKey: "FacebookOAuthTokenTextField")
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
        guard let scope = scopeTextField?.text else {
            return
        }
        guard let consumerKey = consumerKeyTextField?.text else {
            return
        }
        guard let consumerSecret = consumerSecretTextField?.text else {
            return
        }

        let facebook = FacebookOAuthClient(consumerKey: consumerKey, consumerSecret: consumerSecret, scope: scope, callbackURL: callbackURL)
        // facebook.oauthWebViewControllerDelegate = self
        facebook.login { (result) -> Void in
            switch result {
            case .success(_):
                UserDefaults.standard.set(callbackURLString, forKey: "FacebookCallbackURLTextField")
                UserDefaults.standard.set(scope, forKey: "FacebookScopeTextField")
                UserDefaults.standard.set(consumerKey, forKey: "FacebookConsumerKeyTextField")
                UserDefaults.standard.set(consumerSecret, forKey: "FacebookConsumerSecretTextField")
                UserDefaults.standard.set(facebook.oauthToken, forKey: "FacebookOAuthTokenTextField")
                UserDefaults.standard.synchronize()
                self.oauthTokenTextField?.text = facebook.oauthToken
                self.appendConsole("[SUCCESS]")
                self.appendConsole(printCredential(facebook))
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
        guard let scope = scopeTextField?.text else {
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

        let facebook = FacebookOAuthClient(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: oauthToken, scope: scope, callbackURL: callbackURL)
        appendConsole(printCredential(facebook))
        facebook.client.get("https://graph.facebook.com/me?") { result in
            switch result {
            case .success(let response):
                UserDefaults.standard.set(callbackURLString, forKey: "FacebookCallbackURLTextField")
                UserDefaults.standard.set(scope, forKey: "FacebookScopeTextField")
                UserDefaults.standard.set(consumerKey, forKey: "FacebookConsumerKeyTextField")
                UserDefaults.standard.set(consumerSecret, forKey: "FacebookConsumerSecretTextField")
                UserDefaults.standard.set(oauthToken, forKey: "FacebookOAuthTokenTextField")
                UserDefaults.standard.synchronize()
                self.appendConsole("[SUCCESS]")
                if let dataString = response.string {
                    self.appendConsole(debugLog(dataString))
                }
            case .failure(let error):
                self.appendConsole("[ERROR]")
                self.appendConsole(debugLog(error.description))
            }
        }
    }

}

extension FacebookViewController: OAuthWebViewControllerDelegate {

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
