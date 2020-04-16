
import Foundation
import UIKit

enum ConnectorUpdateType {
    case login(success: Bool)
    case receivedData(items: [Item])
    case captcha(image: UIImage)
    case logout
    case search(items: [Item])
}

protocol Pr0grammConnectorObserver: class {
    func connectorDidUpdate(type: ConnectorUpdateType)
}

extension String {
    func base64ToImage() -> UIImage? {
        if let url = URL(string: self),
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) {
            return image
        }
        return nil
    }
}

enum Flags: Int {
    case sfw = 1
    case nsfw = 2
    case nsfl = 4
}

@objc
enum Sorting: Int {
    case top = 1
    case neu = 0
}

enum FetchType {
    case reload
    case more
    case search
}

enum PostType {
    case login
    case voteComment
    case voteItem
    case voteTag
    
    var path: String {
        switch self {
        case .login:
           return ""
        case .voteComment:
           return "comments"
        case .voteItem:
           return "items"
        case .voteTag:
           return "tags"
        }
    }
}

enum Vote: Int {
    case upvote = 1
    case downvote = -1
    case favorite = 2
}

class Pr0grammConnector {

    var observers: [Pr0grammConnectorObserver] = []

    let http = "https://"
    let thumb = "thumb."
    let img = "img."
    let vid = "vid."
    let baseURL = "pr0gramm.com/"
    let top = "api/items/get?flags=3&promoted=0"
    let itemInfo = "api/items/info?itemId="
    var responseModels: [AllItems?] = []
    var searchResponseModel: AllItems?
    var captchaResponse: LoginCaptcha?
    var nonce: String?
    
    private var allItems: [Item] {
        var items = [Item]()
        
        for responseModel in responseModels {
            items += responseModel?.items ?? []
        }
        return items
    }
    
    private var isLoggedIn: Bool {
        guard let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: "https://pr0gramm.com/")!) else { return false }
            
        for cookie in cookies {
            if cookie.name == "me" {
                print("Cookie found. User is logged in.")
                
                let value = cookie.value.removingPercentEncoding?.data(using: .utf8)!
                
                if let json = try? JSONSerialization.jsonObject(with: value!, options: .mutableContainers) as? [String: Any] {
                    if let id = json["id"] as? String {
                        nonce = String(id.prefix(16))
                    }
                }

                return true
            }
        }
        return false
    }
    
    init() {
        URLSession.shared.configuration.httpCookieAcceptPolicy = .always
        AppSettings.isLoggedIn = isLoggedIn
    }
    
    func addObserver(_ observer: Pr0grammConnectorObserver) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: Pr0grammConnectorObserver) {
        for i in observers.indices {
            if observers[i] === observer {
                observers.remove(at: i)
                break
            }
        }
    }
    
    func getCaptcha() {
        let url = URL(string:"https://pr0gramm.com/api/user/captcha")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            let jsonDecoder = JSONDecoder()
            do {
                self.captchaResponse = try jsonDecoder.decode(LoginCaptcha.self, from: data)
                if let image = self.captchaResponse?.captcha?.base64ToImage() {
                    DispatchQueue.main.async {
                        self.observers.forEach { $0.connectorDidUpdate(type: .captcha(image: image))}
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func login(userName: String,
               password: String,
               solvedCaptcha: String) {
        
        let url = URL(string: http + baseURL + "api/user/login")!
        guard let token = captchaResponse?.token else { return }
        let data: [String: String] = ["name": userName,
                                      "password": password,
                                      "token": token,
                                      "captcha": solvedCaptcha]
        post(data: data, to: url, postType: .login) { success in
            print("Login: \(success)")
            AppSettings.isLoggedIn = success
            DispatchQueue.main.async {
                self.observers.forEach { $0.connectorDidUpdate(type: .login(success: success)) }
            }
        }
    }
    
    func logout() {
        let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: "https://pr0gramm.com/")!)
        cookies?.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
        AppSettings.isLoggedIn = false
        observers.forEach { $0.connectorDidUpdate(type: .logout) }
    }
    
    //"description": "-1 = Minus, 1 = Plus, 2 = Fav, 0 = Kein Vote/Vote zurückziehen",
    
    func vote(id: Int, value: Vote, type: PostType) {
        guard let nonce = nonce else { return }
        let data: [String: String] = ["id": "\(id)",
                                      "vote": "\(value.rawValue)",
                                      "_nonce": nonce]
        
        let url = URL(string: http + baseURL + "api/\(type.path)/vote")!
        post(data: data, to: url, postType: .voteItem) { success in
            print("Voted \(type.path): \(success)")
        }
    }
    
    private func post(data: [String: String], to url: URL, postType: PostType, completion: @escaping (Bool) -> Void) {
        let jsonString = data.reduce("") { "\($0)\($1.0)=\($1.1)&" }
        let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard let data = data else { completion(false); return }
            
            do {
                let jsonDecoder = JSONDecoder()
                switch postType {
                case .login:
                    let responseModel = try jsonDecoder.decode(Login.self, from: data)
                    completion(responseModel.success ?? false)
                case .voteTag, .voteItem, .voteComment:
                    completion(true)
                }
            } catch {
                print(error.localizedDescription)
                completion(false)
            }
        })
        task.resume()
    }

    func clearItems() {
        responseModels.removeAll()
    }
    
    func fetchItems(sorting: Sorting, flags: [Flags], more: Bool = false) {
        
        let flagsCombined = flags.reduce(0, { $0 + $1.rawValue })
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "pr0gramm.com"
        components.path = "/api/items/get"
        components.queryItems = [
            URLQueryItem(name: "flags", value: "\(flagsCombined)"),
            URLQueryItem(name: "promoted", value: "\(sorting.rawValue)")
        ]
        
        switch sorting {
        case .top:
            if more, let promotedId = allItems.last?.promoted {
                components.queryItems?.append(URLQueryItem(name: "older", value: "\(promotedId)"))
            }
        case .neu:
            if more, let lastId = allItems.last?.id {
                components.queryItems?.append(URLQueryItem(name: "older", value: "\(lastId)"))
            }
        }
        
        
        guard let url = components.url else { return }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"

        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            let jsonDecoder = JSONDecoder()
            do {
                let responseModel = try jsonDecoder.decode(AllItems.self, from: data)
                self.responseModels.append(responseModel)
                DispatchQueue.main.async {
                    self.observers.forEach { $0.connectorDidUpdate(type: .receivedData(items: self.allItems)) }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
        
    func searchItems(for tags: [String], completion: @escaping ([Item]) -> Void) {
        guard let tag = tags[0].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        let url = URL(string: "https://pr0gramm.com/api/items/get?flags=3&promoted=1&tags=\(tag)")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"

        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            let jsonDecoder = JSONDecoder()
            do {
                let searchResponse = try jsonDecoder.decode(AllItems.self, from: data)
                DispatchQueue.main.async {
                    completion(searchResponse.items)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func thumbLink(for item: Item) -> String {
        let link = http + thumb + baseURL + item.thumb
        return link
    }
    
    func link(for item: Item) -> (link: String, mediaType: MediaType) {
        if item.image.hasSuffix(".mp4") {
            return (http + vid + baseURL + item.image, .video)
        } else if item.image.hasSuffix(".gif") {
            return (http + img + baseURL + item.image, .gif)
        } else {
            return (http + img + baseURL + item.image, .image)
        }
    }

    func loadItemInfo(for id: Int, completion: @escaping (ItemInfo?) -> Void) {
        let url = URL(string: http + baseURL + itemInfo + "\(id)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else { return }
            let jsonDecoder = JSONDecoder()
            do {
                let itemInfo = try jsonDecoder.decode(ItemInfo.self, from: data)
                completion(itemInfo)
            } catch let error {
                print(error.localizedDescription)
                completion(nil)
            }
        }
        task.resume()
    }
}
