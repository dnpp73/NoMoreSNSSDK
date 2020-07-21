import UIKit
import NoMoreSNSSDK
import OAuthSwift

final class GoogleViewController: UITableViewController {

    @IBOutlet private var callbackURLTextField: UITextField!
    @IBOutlet private var scopeTextField: UITextField!
    @IBOutlet private var consumerKeyTextField: UITextField!
    @IBOutlet private var consumerSecretTextField: UITextField!
    @IBOutlet private var oauthTokenTextField: UITextField!

    @IBOutlet private var consoleTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        callbackURLTextField.text = UserDefaults.standard.string(forKey: "GoogleCallbackURLTextField")
        scopeTextField.text = UserDefaults.standard.string(forKey: "GoogleScopeTextField")
        consumerKeyTextField.text = UserDefaults.standard.string(forKey: "GoogleConsumerKeyTextField")
        consumerSecretTextField.text = UserDefaults.standard.string(forKey: "GoogleConsumerSecretTextField")
        oauthTokenTextField.text = UserDefaults.standard.string(forKey: "GoogleOAuthTokenTextField")
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

        let google = GoogleOAuthClient(consumerKey: consumerKey, consumerSecret: consumerSecret, scope: scope, callbackURL: callbackURL)
        // google.oauthWebViewControllerDelegate = self
        google.login { (result) -> Void in
            switch result {
            case .success(_):
                UserDefaults.standard.set(callbackURLString, forKey: "GoogleCallbackURLTextField")
                UserDefaults.standard.set(scope, forKey: "GoogleScopeTextField")
                UserDefaults.standard.set(consumerKey, forKey: "GoogleConsumerKeyTextField")
                UserDefaults.standard.set(consumerSecret, forKey: "GoogleConsumerSecretTextField")
                UserDefaults.standard.set(google.oauthToken, forKey: "GoogleOAuthTokenTextField")
                UserDefaults.standard.synchronize()
                self.oauthTokenTextField?.text = google.oauthToken
                self.appendConsole("[SUCCESS]")
                self.appendConsole(printCredential(google))
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

        let google = GoogleOAuthClient(consumerKey: consumerKey, consumerSecret: consumerSecret, oauthToken: oauthToken, scope: scope, callbackURL: callbackURL)
        appendConsole(printCredential(google))
        google.client.get("https://www.googleapis.com/oauth2/v1/userinfo?") { result in
            switch result {
            case .success(let response):
                UserDefaults.standard.set(callbackURLString, forKey: "GoogleCallbackURLTextField")
                UserDefaults.standard.set(scope, forKey: "GoogleScopeTextField")
                UserDefaults.standard.set(consumerKey, forKey: "GoogleConsumerKeyTextField")
                UserDefaults.standard.set(consumerSecret, forKey: "GoogleConsumerSecretTextField")
                UserDefaults.standard.set(oauthToken, forKey: "GoogleOAuthTokenTextField")
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

extension GoogleViewController: OAuthWebViewControllerDelegate {

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
