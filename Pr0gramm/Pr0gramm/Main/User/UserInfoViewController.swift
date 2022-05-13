
import UIKit
import ScrollingContentViewController

class UserInfoViewController: ScrollingContentViewController, Storyboarded {
    
    weak var coordinator: Coordinator?
    var viewModel: UserInfoViewModel!
    @IBOutlet private var notLoggedInStackView: UIStackView!
    @IBOutlet private var loggedInStackView: UIStackView!
    @IBOutlet private var scoreLabel: UILabel!
    @IBOutlet private var userClassDotView: UserClassDotView!
    @IBOutlet private var userClassLabel: UILabel!
    @IBOutlet private var collectionsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        
        let _ = viewModel.isLoggedIn.observeNext(with: { [weak self] isLoggedIn in
            if isLoggedIn {
                self?.showLoggedIn()
            } else {
                self?.showLoggedOut()
            }
        })
                        
        let badgesCollectionViewController = BadgesCollectionViewController.fromStoryboard()
        badgesCollectionViewController.viewModel = viewModel
        addChild(badgesCollectionViewController)
        loggedInStackView.insertArrangedSubview(badgesCollectionViewController.view, at: 1)
        badgesCollectionViewController.didMove(toParent: self)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        scoreLabel.addInteraction(interaction)
        scoreLabel.isUserInteractionEnabled = true
        
        
        let _ = viewModel.userInfo.observeNext { [weak self] userInfo in
            guard let userInfo = userInfo else { return }
            self?.scoreLabel.text = "Benis: \(userInfo.user.score)"
            self?.userClassDotView.backgroundColor = Colors.color(for: userInfo.user.mark)
            self?.userClassLabel.text = Strings.userClass(for: userInfo.user.mark)
            self?.collectionsButton.setTitle("Sammlungen (\(userInfo.collections?.count ?? 0))", for: .normal)
        }
                
        let _ = viewModel.name.observeNext(with: { [weak self] name in
            self?.title = name
            self?.tabBarItem = UITabBarItem(title: "Profil",
                                            image: UIImage(systemName: "person.circle"),
                                            selectedImage: UIImage(systemName: "person.circle.fill"))
        })
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
              let name = viewModel.name.value else { return }
        
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
        ↑ \(viewModel.userInfo.value?.user.up ?? 0)
        ↓ \(viewModel.userInfo.value?.user.down ?? 0)
        """
        
        return UIMenu(title: title, children: [okAction])
    }
}

