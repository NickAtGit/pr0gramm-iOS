
import UIKit
import ScrollingContentViewController

class UserInfoViewController: ScrollingContentViewController, Storyboarded {
    
    weak var coordinator: Coordinator?
    var viewModel: UserInfoViewModel!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var scoreLabel: UILabel!
    @IBOutlet private var userClassDotView: UserClassDotView!
    @IBOutlet private var userClassLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        tabBarItem = UITabBarItem(title: "Profil",
                                  image: UIImage(systemName: "person.circle"),
                                  selectedImage: UIImage(systemName: "person.circle.fill"))
        
        let badgesCollectionViewController = BadgesCollectionViewController.fromStoryboard()
        badgesCollectionViewController.viewModel = viewModel
        addChild(badgesCollectionViewController)
        stackView.insertArrangedSubview(badgesCollectionViewController.view, at: 2)
        badgesCollectionViewController.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scoreLabel.text = "Benis: \(viewModel.score)"
        userClassDotView.backgroundColor = Colors.color(for: viewModel.userClass)
        userClassLabel.text = Strings.userClass(for: viewModel.userClass)
    }
    
    @IBAction func showLikesButtonTapped(_ sender: Any) {
        guard let navigationController = navigationController else { return }
        coordinator?.showCollections(viewModel: viewModel,
                                     navigationController: navigationController)
    }
    
    @IBAction func showUserUploadsButtonTapped(_ sender: Any) {
        guard let navigationController = navigationController else { return }
        coordinator?.showUserPosts(for: .user,
                                   navigationController: navigationController)
    }
}
