
import UIKit

class UserInfoViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: UserInfoViewModel!
    @IBOutlet private var scoreLabel: UILabel!
    
    var userInfo: UserInfo? {
        didSet {
            guard let userInfo = userInfo else { return }
            scoreLabel.text = "Benis: \(userInfo.user.score)"
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
