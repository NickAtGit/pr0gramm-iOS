
import UIKit
import ScrollingContentViewController

class LoginViewController: ScrollingContentViewController, StoryboardInitialViewController {
    
    weak var coordinator: Coordinator?
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var captchaTextField: UITextField!
    @IBOutlet var captchaImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coordinator?.pr0grammConnector.addObserver(self)
        coordinator?.pr0grammConnector.getCaptcha()
        userNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coordinator?.pr0grammConnector.removeObserver(self)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let solvedCaptcha = captchaTextField.text,
            let userName = userNameTextField.text,
            let password = passwordTextField.text else { return }
        coordinator?.pr0grammConnector.login(userName: userName,
                                             password: password,
                                             solvedCaptcha: solvedCaptcha)
    }
}

extension LoginViewController: Pr0grammConnectorObserver {
    
    func connectorDidUpdate(type: ConnectorUpdateType) {
        switch type {
        case .login(let success):
            if success {
                self.dismiss(animated: true)
            } else {
                let navigationContoller = self.navigationController as! NavigationController
                navigationContoller.showBanner(with: "Login fehlgeschlagen")
                coordinator?.pr0grammConnector.getCaptcha()
            }
        case .captcha(let image):
            self.captchaImageView.image = image
        default:
            break
        }
    }
}
