
import UIKit

extension UIViewController {
    
    var navigation: NavigationController? {
        return UIApplication.shared.windows.first?.topVisibleViewController?.navigationController as? NavigationController
    }
    
    func embed(_ viewController: UIViewController){
        viewController.willMove(toParent: self)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    func embed(_ viewController: UIViewController, in view: UIView) {
        
        viewController.beginAppearanceTransition(true, animated: true)
        viewController.willMove(toParent: self)
        viewController.view.frame = view.bounds
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            viewController.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewController.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        self.addChild(viewController)
        viewController.didMove(toParent: self)
        viewController.endAppearanceTransition()
    }
    
    @objc
    func dismissSelf() {
        dismiss(animated: true)
    }
}

extension UIWindow {
    /// returns the frontmost view controller in the view controller hierarchy (starting with the window's root view controller)
    public var topVisibleViewController: UIViewController? {
        guard let rootViewController = rootViewController else {
            return nil
        }
        return rootViewController.topVisibleViewController
    }
}

extension UIViewController {
    /// returns the frontmost view controller in die view controller hierarchy (starting with self)
    @objc
    public var topVisibleViewController: UIViewController? {
        if let topVisibleViewController = presentedViewController?.topVisibleViewController {
            return topVisibleViewController
        } else if let topVisibleViewController = children.first?.topVisibleViewController {
            return topVisibleViewController
        } else {
            return self
        }
    }
}

extension UINavigationController {
    /// returns the frontmost view controller in die view controller hierarchy (starting with self)
    public override var topVisibleViewController: UIViewController? {
        guard let topVisibleViewController = visibleViewController?.topVisibleViewController else {
            return self
        }
        return topVisibleViewController
    }
}

