
import UIKit
import ScrollingContentViewController
import Combine

class UserInfoViewController: ScrollingContentViewController, Storyboarded {
    
    weak var coordinator: Coordinator?
    var viewModel: UserInfoViewModel!
    @IBOutlet private var notLoggedInStackView: UIStackView!
    @IBOutlet private var loggedInStackView: UIStackView!
    @IBOutlet private var scoreLabel: UILabel!
    @IBOutlet private var userClassView: UIImageView!
    @IBOutlet private var userClassLabel: UILabel!
    @IBOutlet private var collectionsButton: UIButton!
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        
        viewModel.$isLoggedIn
            .sink(receiveValue: { [weak self] isLoggedIn in
                if isLoggedIn {
                    self?.showLoggedIn()
                } else {
                    self?.showLoggedOut()
                }
            })
            .store(in: &subscriptions)
        
        let badgesCollectionViewController = BadgesCollectionViewController.fromStoryboard()
        badgesCollectionViewController.viewModel = viewModel
        addChild(badgesCollectionViewController)
        loggedInStackView.insertArrangedSubview(badgesCollectionViewController.view, at: 1)
        badgesCollectionViewController.didMove(toParent: self)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        scoreLabel.addInteraction(interaction)
        scoreLabel.isUserInteractionEnabled = true
        
        
        viewModel.$userInfo
            .sink(receiveValue: { [weak self] userInfo in
                guard let userInfo = userInfo else { return }
                self?.scoreLabel.text = "Benis: \(userInfo.user.score)"
                self?.userClassView.image = userInfo.user.mark.icon
                self?.userClassLabel.text = userInfo.user.mark.title
                self?.collectionsButton.setTitle("Sammlungen (\(userInfo.collections?.count ?? 0))", for: .normal)
            })
            .store(in: &subscriptions)
        
        viewModel.$name
            .sink(receiveValue: { [weak self] name in
                self?.title = name
                self?.tabBarItem = UITabBarItem(title: "Profil",
                                                image: UIImage(systemName: "person.circle"),
                                                selectedImage: UIImage(systemName: "person.circle.fill"))
            })
            .store(in: &subscriptions)
    }
    
    private func showLoggedIn() {
        loggedInStackView.isHidden = false
        notLoggedInStackView.isHidden = true
    }
    
    private func showLoggedOut() {
        loggedInStackView.isHidden = true
        notLoggedInStackView.isHidden = false
    }
        
    @IBAction func showCollectionsButtonTapped(_ sender: Any) {
        guard let navigationController = navigationController else { return }
        coordinator?.showCollections(viewModel: viewModel,
                                     navigationController: navigationController)
    }
    
    @IBAction func showUserUploadsButtonTapped(_ sender: Any) {
        guard let navigationController = navigationController,
              let name = viewModel.name else { return }
        
        coordinator?.showUserPosts(for: .user(name: name),
                                   navigationController: navigationController)
    }
    
    @IBAction func showMessages() {
        let url = URL(string: "https://pr0gramm.com/inbox/messages")!
        coordinator?.showWebViewViewController(for: url, from: self)
    }
}

extension UserInfoViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            return self.createContextMenu()
        }
    }
    
    func createContextMenu() -> UIMenu {
        let okAction = UIAction(title: "Ok", image: UIImage(systemName: "checkmark.circle")) { _ in }
        
        let title = """
        ↑ \(viewModel.userInfo?.user.up ?? 0)
        ↓ \(viewModel.userInfo?.user.down ?? 0)
        """
        
        return UIMenu(title: title, children: [okAction])
    }
}

