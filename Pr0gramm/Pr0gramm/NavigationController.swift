
import UIKit

enum NavigationControllerStyle {
    case login, detail
}

class NavigationController: UINavigationController {
    
    weak var coordinator: Coordinator?

    var style: NavigationControllerStyle? {
        didSet {
            setupBarButtonItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBanner()
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        setupBarButtonItems()
    }
    
    private func setupBarButtonItems() {
        
        guard let style = style else { return }
        
        switch style {
        case .login:
            let logoutItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.badge.minus"),
                                             style: .plain,
                                             target: coordinator,
                                             action: #selector(Coordinator.logout))
            topViewController?.navigationItem.rightBarButtonItem = logoutItem
        case .detail:
            break
        }
    }
    
    var navigationBannerView: NavigationBannerView!

    private func setupBanner() {
        //BannerView
        navigationBannerView = NavigationBannerView(frame: .zero)
        view.addSubview(navigationBannerView)
        view.bringSubviewToFront(navigationBannerView)
        
        navigationBannerView.translatesAutoresizingMaskIntoConstraints = false
        navigationBannerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        navigationBannerView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0).isActive = true
        navigationBannerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        navigationBannerView.heightAnchor.constraint(equalToConstant: 34).isActive = true
        navigationBannerView.alpha = 0
    }
    
    func showBanner(with message: String, duration: TimeInterval = 1.5) {
        navigationBannerView.show(message: message, for: duration)
    }
}


class NavigationBannerView: UIView {

    private let messageTextLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.3019607843, blue: 0.1803921569, alpha: 1)
        messageTextLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextLabel.numberOfLines = 0
        messageTextLabel.textColor = .white
        addSubview(messageTextLabel)
        NSLayoutConstraint.activate([
            messageTextLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageTextLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
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
