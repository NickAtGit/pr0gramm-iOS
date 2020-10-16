
import Foundation
import Bond

class UserInfoViewModel: Pr0grammConnectorObserver {
    
    private let connector: Pr0grammConnector
    let userInfo = Observable<UserInfo?>(nil)
    let isLoggedIn = Observable<Bool>(false)
    let name = Observable<String?>(nil)
    
    init(name: String? = nil, connector: Pr0grammConnector) {
        self.name.value = name ?? connector.userName
        self.connector = connector
        self.connector.addObserver(self)
        isLoggedIn.value = connector.isLoggedIn
        loadUserInfo()
    }
    
    private func loadUserInfo() {
        guard let name = name.value else { return }
        connector.fetchUserInfo(for: name) { [weak self] userInfo in
            guard let userInfo = userInfo else { return }
            DispatchQueue.main.async {
                self?.userInfo.value = userInfo
            }
        }
    }
    
    func connectorDidUpdate(type: ConnectorUpdateType) {
        switch type {
        case .login(success: let success):
            if success {
                name.value = connector.userName
                loadUserInfo()
            }
            isLoggedIn.value = success
        case .captcha:
            break
        case .logout:
            name.value = ""
            isLoggedIn.value = false
        }
    }
}
