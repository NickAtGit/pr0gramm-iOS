
import Foundation

class UserInfoViewModel: Pr0grammConnectorObserver {
    
    private let connector: Pr0grammConnector
    @Published var userInfo: UserInfo?
    @Published var isLoggedIn = false
    @Published var name: String?
    
    init(name: String? = nil, connector: Pr0grammConnector) {
        self.name = name ?? connector.userName
        self.connector = connector
        self.connector.addObserver(self)
        isLoggedIn = AppSettings.isLoggedIn
        loadUserInfo()
    }
    
    private func loadUserInfo() {
        guard let name else { return }
        connector.fetchUserInfo(for: name) { [weak self] userInfo in
            guard let userInfo = userInfo else { return }
            DispatchQueue.main.async {
                self?.userInfo = userInfo
            }
        }
    }
    
    func connectorDidUpdate(type: ConnectorUpdateType) {
        switch type {
        case .login(success: let success):
            if success {
                name = connector.userName
                loadUserInfo()
            }
            isLoggedIn = success
        case .captcha:
            break
        case .logout:
            name = ""
            isLoggedIn = false
        }
    }
}
