
import Foundation
import Bond

class UserInfoViewModel {
    
    private let connector: Pr0grammConnector
    let userInfo = Observable<UserInfo?>(nil)
    let name: String
    
    init(name: String? = nil, connector: Pr0grammConnector) {
        self.name = name ?? connector.userName ?? ""
        self.connector = connector
        loadUserInfo()
    }
    
    private func loadUserInfo() {
        connector.fetchUserInfo(for: name) { userInfo in
            guard let userInfo = userInfo else { return }
            DispatchQueue.main.async {
                self.userInfo.value = userInfo
            }
        }
    }
}
