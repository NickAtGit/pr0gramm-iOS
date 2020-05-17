
import UIKit
import ScrollingContentViewController

class UserInfoViewController: ScrollingContentViewController, StoryboardInitialViewController {
    
    var viewModel: UserInfoViewModel!
    @IBOutlet private var scoreLabel: UILabel!
    @IBOutlet private var userClassDotView: UserClassDotView!
    @IBOutlet private var userClassLabel: UILabel!
    
    var userInfo: UserInfo? {
        didSet {
            guard let userInfo = userInfo else { return }
            scoreLabel.text = "Benis: \(userInfo.user.score)"
            userClassDotView.backgroundColor = Colors.color(for: userInfo.user.mark)
            userClassLabel.text = Strings.userClass(for: userInfo.user.mark)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        tabBarItem = UITabBarItem(title: "Profil",
                                  image: UIImage(systemName: "person.circle"),
                                  selectedImage: UIImage(systemName: "person.circle.fill"))
        
        viewModel.loadUserInfo { success in
            if success {
                self.userInfo = self.viewModel.userInfo
            }
        }
    }
}
