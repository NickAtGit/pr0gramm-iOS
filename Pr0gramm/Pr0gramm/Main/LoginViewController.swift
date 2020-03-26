
import UIKit

class LoginViewController: UIViewController, StoryboardInitialViewController, LoginDelegate {
    
    weak var coordinator: Coordinator?
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var captchaTextField: UITextField!
    @IBOutlet var captchaImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator?.pr0grammConnector.loginDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coordinator?.pr0grammConnector.getCaptcha()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let solvedCaptcha = captchaTextField.text,
            let userName = userNameTextField.text,
            let password = passwordTextField.text else { return }
        coordinator?.pr0grammConnector.login(userName: userName,
                                             password: password,
                                             solvedCaptcha: solvedCaptcha)
    }
        
    func didReceiveCaptcha(image: UIImage) {
        DispatchQueue.main.async {
            self.captchaImageView.image = image
        }
    }
    
    func didLogin(successful: Bool) {
        if successful {
            DispatchQueue.main.async {
                self.coordinator?.showOverview()
            }
        }
    }
}
