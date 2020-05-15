
import Foundation

class UserInfoViewModel {
    
    private let connector: Pr0grammConnector
    var userInfo: UserInfo?

    var title: String? { connector.userName }
    
    init(connector: Pr0grammConnector) {
        self.connector = connector
    }
    
    func loadUserInfo(completion: @escaping (Bool) -> Void) {
        connector.fetchUserInfo { userInfo in
            guard let userInfo = userInfo else { completion(false); return }
            DispatchQueue.main.async {
                self.userInfo = userInfo
                completion(true)
            }
        }
    }
}
