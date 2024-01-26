
import UIKit
import SwiftUI

enum NavigationControllerStyle {
    case main, dismissable, dragable, user, search
}

class NavigationController: UINavigationController, UIPopoverPresentationControllerDelegate {
    
    weak var coordinator: Coordinator?
    private var navigationBannerView = NavigationBannerView(frame: .zero)
    
    lazy var setFilterBarButtonItem = {
        let flagsItem = UIBarButtonItem(image: UIImage(systemName: "list.dash"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(self.showFilterPopover(_:)))
        self.topViewController?.navigationItem.rightBarButtonItem = flagsItem
    }

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
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        if viewController is PostsOverviewCollectionViewController {
            setFilterBarButtonItem()
        }
    }
    
    private func setupBarButtonItems() {
        
        guard let style = style else { return }
        
        switch style {
        case .dragable:
            let dismissItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(dismissSelf))
            topViewController?.navigationItem.rightBarButtonItem = dismissItem
            
        case .main:
            setFilterBarButtonItem()
            
        case .user:
            setFilterBarButtonItem()
            
            if AppSettings.isLoggedIn {
                let logoutItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.minus"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(confirmLogout))
                topViewController?.navigationItem.leftBarButtonItem = logoutItem
            } else {
                let loginItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.plus"),
                                                style: .plain,
                                                target: coordinator,
                                                action: #selector(Coordinator.showLogin))
                topViewController?.navigationItem.leftBarButtonItem = loginItem
            }

        case .dismissable:
            let dismissItem = UIBarButtonItem(image: UIImage(systemName: "xmark"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(dismissSelf))
            topViewController?.navigationItem.leftBarButtonItem = dismissItem
        case .search:
            setFilterBarButtonItem()
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
    func showFilterPopover(_ sender: UIBarButtonItem) {
        let filterViewController = UIHostingController(rootView: FilterView())
        filterViewController.modalPresentationStyle = .popover
        filterViewController.popoverPresentationController?.sourceView = view
        filterViewController.popoverPresentationController?.permittedArrowDirections = .up
        filterViewController.popoverPresentationController?.barButtonItem = sender
        filterViewController.popoverPresentationController?.delegate = self
      
        let popoverSize = CGSize(width: 200, height: filterViewController.view.bounds.height)
        let idealPopoverSize = filterViewController.sizeThatFits(in: popoverSize)
        filterViewController.preferredContentSize = idealPopoverSize
        
        present(filterViewController, animated: true)
    }
    
    @objc
    func confirmLogout() {
        let alert = UIAlertController(title: "Obacht!",
                                      message: "Du bist dabei dich auszuloggen. Möchtest du das?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ja", style: .destructive) { _ in
            self.coordinator?.logout()
        })
        alert.addAction(UIAlertAction(title: "Nein", style: .cancel))

        present(alert, animated: true)
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        NotificationCenter.default.post(name: Notification.Name("flagsChanged"), object: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { .none }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
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
        messageTextLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextLabel.numberOfLines = 0
        messageTextLabel.textAlignment = .center
        messageTextLabel.textColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
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
