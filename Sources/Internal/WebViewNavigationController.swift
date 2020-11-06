import UIKit
import OAuthSwift

final class WebViewNavigationController: UINavigationController, OAuthSwiftURLHandlerType {
    func handle(_ url: URL) {
        guard let topMost = UIViewController.topMost, let webViewController = topViewController as? WebViewController, viewControllers.first == webViewController else {
            fatalError("Invalid ViewController Stack.")
        }
        let completion: () -> Void = {
            webViewController.handle(url)
            webViewController.delegate?.oauthWebViewControllerDidPresent()
        }
        topMost.present(self, animated: webViewController.presentViewControllerAnimated, completion: completion)
    }
}

extension UIViewController {
    private var topMost: UIViewController {
        // Handling Modal views
        if let navigationController = self as? UINavigationController, let topViewController = navigationController.topViewController {
            return topViewController.topMost
        } else if let tabBarController = self as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.topMost
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.topMost
        } else {
            // Handling UIViewController's added as subviews to some other views.
            for view in self.view.subviews {
                // Key property which most of us are unaware of / rarely use.
                if let subViewController = view.next as? UIViewController {
                    return subViewController.topMost
                }
            }
            return self
        }
    }
    fileprivate static var topMost: UIViewController? {
        UIApplication.shared.keyWindow?.rootViewController?.topMost
    }
}
