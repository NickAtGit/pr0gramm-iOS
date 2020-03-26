
import UIKit

extension UIViewController {
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
}
