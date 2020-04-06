
import UIKit

class LoginViewController: UIViewController, StoryboardInitialViewController {
    
    weak var coordinator: Coordinator?
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var captchaTextField: UITextField!
    @IBOutlet var captchaImageView: UIImageView!
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coordinator?.pr0grammConnector.addObserver(self)
        coordinator?.pr0grammConnector.getCaptcha()
        userNameTextField.becomeFirstResponder()
    }
    
    deinit {
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
    func didLogout() {}
    func didReceiveData() {}
    
    func didReceiveCaptcha(image: UIImage) {
        DispatchQueue.main.async {
            self.captchaImageView.image = image
        }
    }
    
    func didLogin(successful: Bool) {
        if successful {
            self.dismiss(animated: true)
        } else {
            let navigationContoller = self.navigationController as! NavigationController
            navigationContoller.showBanner(with: "Login fehlgeschlagen")
        }
    }
}
