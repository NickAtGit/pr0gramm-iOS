
import UIKit

class NavigationController: UINavigationController {
    
    weak var coordinator: Coordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        setupBarButtonItems()
    }
    
    private func setupBarButtonItems() {
        if #available(iOS 13.0, *) {
            let logoutItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.minus"),
                                             style: .plain,
                                             target: coordinator,
                                             action: #selector(Coordinator.logout))
            topViewController?.navigationItem.rightBarButtonItem = logoutItem
        } else {
            let logoutItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                             target: coordinator,
                                             action: #selector(Coordinator.logout))
            topViewController?.navigationItem.rightBarButtonItem = logoutItem
        }
    }
}
