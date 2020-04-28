
import UIKit

enum NavigationControllerStyle {
    case main, dismissable, dragable
}

class NavigationController: UINavigationController, UIPopoverPresentationControllerDelegate {
    
    weak var coordinator: Coordinator?
    private var navigationBannerView = NavigationBannerView(frame: .zero)

    var style: NavigationControllerStyle? {
        didSet {
            setupBarButtonItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coordinator?.pr0grammConnector.addObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coordinator?.pr0grammConnector.removeObserver(self)
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        setupBarButtonItems()
    }
    
    private func setupBarButtonItems() {
        
        guard let style = style else { return }
        
        switch style {
        case .dragable:
            let flagsItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(dismissSelf))
            topViewController?.navigationItem.rightBarButtonItem = flagsItem

        case .main:
            let flagsItem = UIBarButtonItem(image: UIImage(systemName: "list.dash"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(showFlagsPopover(_:)))
            topViewController?.navigationItem.leftBarButtonItem = flagsItem
            
            if AppSettings.isLoggedIn {
                let logoutItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.minus"),
                                                 style: .plain,
                                                 target: coordinator,
                                                 action: #selector(Coordinator.logout))
                topViewController?.navigationItem.rightBarButtonItem = logoutItem
            } else {
                //UIImage(systemName: "person.crop.circle.badge.plus")
                let loginItem = UIBarButtonItem(image: nil,
                                                style: .plain,
                                                target: coordinator,
                                                action: #selector(Coordinator.showLogin))
                
                topViewController?.navigationItem.rightBarButtonItem = loginItem
            }

        case .dismissable:
            let flagsItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(dismissSelf))
            topViewController?.navigationItem.rightBarButtonItem = flagsItem
        }
    }
    

    private func setupBanner() {
        view.addSubview(navigationBannerView)
        view.bringSubviewToFront(navigationBannerView)
        navigationBannerView.translatesAutoresizingMaskIntoConstraints = false
        navigationBannerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        navigationBannerView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0).isActive = true
        navigationBannerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        navigationBannerView.alpha = 0
    }
    
    func showBanner(with message: String, duration: TimeInterval = 1.5) {
        navigationBannerView.show(message: message, for: duration)
    }
    
    @objc
    func showFlagsPopover(_ sender: UIBarButtonItem) {
        let flagsViewController = FlagsViewController.fromStoryboard()
        flagsViewController.modalPresentationStyle = .popover
        flagsViewController.popoverPresentationController?.sourceView = view
        flagsViewController.popoverPresentationController?.permittedArrowDirections = .up

        let popover: UIPopoverPresentationController = flagsViewController.popoverPresentationController!
        popover.barButtonItem = sender
        popover.delegate = self
        
        present(flagsViewController, animated: true)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        coordinator?.pr0grammConnector.clearItems()
        coordinator?.pr0grammConnector.fetchItems(sorting: Sorting(rawValue: AppSettings.sorting)!,
                                                  flags: AppSettings.currentFlags)

        
        if let mainCollectionViewController = topViewController as? MainCollectionViewController {
            mainCollectionViewController.updateTabBarItem(for: Sorting(rawValue: AppSettings.sorting)!)
        }
    }
}

extension NavigationController: Pr0grammConnectorObserver {
    
    func connectorDidUpdate(type: ConnectorUpdateType) {
        switch type {
        case .login(_):
            setupBarButtonItems()
        case .logout:
            setupBarButtonItems()
        default:
            break
        }
    }
}





class NavigationBannerView: UIView {

    private let messageTextLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.3019607843, blue: 0.1803921569, alpha: 1)
        messageTextLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextLabel.numberOfLines = 0
        messageTextLabel.textAlignment = .center
        addSubview(messageTextLabel)
        
        NSLayoutConstraint.activate([
            messageTextLabel.leftAnchor.constraint(equalTo: leftAnchor),
            messageTextLabel.rightAnchor.constraint(equalTo: rightAnchor),
            messageTextLabel.topAnchor.constraint(equalTo: topAnchor),
            messageTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func show(message: String, for duration: TimeInterval) {
        messageTextLabel.text = message
        fadeInfadeOut(for: duration)
    }
    
    private func fadeInfadeOut(for duration: TimeInterval) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1
        }) { (done) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration, execute: {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 0
                })
            })
        }
    }
}
