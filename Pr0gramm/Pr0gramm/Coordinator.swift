
import UIKit

class Coordinator {
    
    let pr0grammConnector = Pr0grammConnector()
    let navigationController = NavigationController()
    
    init() {
        navigationController.coordinator = self
    }
    
    func startViewController() -> UIViewController {
        
        if pr0grammConnector.isLoggedIn {
            let viewController = MainCollectionViewController.fromStoryboard()
            viewController.coordinator = self
            navigationController.viewControllers = [viewController]
            return navigationController
        } else {
            let viewController = LoginViewController.fromStoryboard()
            viewController.coordinator = self
            navigationController.viewControllers = [viewController]
            return navigationController
        }
    }
    
    func showLogin() {
        let viewController = LoginViewController.fromStoryboard()
        viewController.coordinator = self
        navigationController.viewControllers = [viewController]
    }
    
    func showOverview() {
        let viewController = MainCollectionViewController.fromStoryboard()
        viewController.coordinator = self
        navigationController.viewControllers = [viewController]
    }
    
    func showDetail(for item: Item, at indexPath: IndexPath) {
        let viewController = DetailCollectionViewController.fromStoryboard()
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
        viewController.scrollTo(indexPath: indexPath)
    }
    
    func showShareSheet(with items: [Any]) {
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        navigationController.present(ac, animated: true)
    }
    
    @objc
    func logout() {
        pr0grammConnector.logout()
        showLogin()
    }
}
