
import UIKit

class TVLoginViewController: UIViewController, Storyboarded {
    
    weak var coordinator: TVCoordinator?
    var connector: Pr0grammConnector!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var captchaTextField: UITextField!
    @IBOutlet var captchaImageView: UIImageView!
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connector.addObserver(self)
        connector.getCaptcha()
        userNameTextField.becomeFirstResponder()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        guard let solvedCaptcha = captchaTextField.text,
            let userName = userNameTextField.text,
            let password = passwordTextField.text else { return }
        connector.login(userName: userName,
                        password: password,
                        solvedCaptcha: solvedCaptcha)
    }
}

extension TVLoginViewController: Pr0grammConnectorObserver {
    
    func connectorDidUpdate(type: ConnectorUpdateType) {
        switch type {
        case .login(let success):
            if success {
                coordinator?.showTVDetail()
            } else {
                
            }
        case .captcha(let image):
            self.captchaImageView.image = image
        default:
            break
        }
    }
}
