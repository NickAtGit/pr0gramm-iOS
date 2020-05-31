
import Foundation

class UserInfoViewModel {
    
    private let connector: Pr0grammConnector
    var userInfo: UserInfo?
    var score: Int { userInfo?.user.score ?? 0 }
    var userClass: Int { userInfo?.user.mark ?? 0 }
    var title: String? { connector.userName }
    
    init(connector: Pr0grammConnector) {
        self.connector = connector
        loadUserInfo()
    }
    
    private func loadUserInfo() {
        connector.fetchUserInfo { userInfo in
            guard let userInfo = userInfo else { return }
            DispatchQueue.main.async {
                self.userInfo = userInfo
            }
        }
    }
}
