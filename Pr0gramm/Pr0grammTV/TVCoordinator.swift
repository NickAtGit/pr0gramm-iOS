
import UIKit

class TVCoordinator {
    
    let connector = Pr0grammConnector()
    let navigationController = UINavigationController()
    
    func startViewController() -> UIViewController {
        
        let viewController: UIViewController
        
        if connector.isLoggedIn {
            let tvViewController = TVViewController.fromStoryboard()
            tvViewController.viewModel = TVViewModel(connector: connector)
            viewController = tvViewController
        } else {
            let loginViewController = TVLoginViewController.fromStoryboard()
            loginViewController.connector = connector
            viewController = loginViewController
        }
        navigationController.viewControllers = [viewController]
        return navigationController
    }
    
    func showTVDetail() {
        let tvViewController = TVViewController.fromStoryboard()
        tvViewController.viewModel = TVViewModel(connector: connector)
        navigationController.pushViewController(tvViewController, animated: true)
    }
}
