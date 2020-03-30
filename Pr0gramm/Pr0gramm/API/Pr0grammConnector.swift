
import Foundation
import UIKit

protocol Pr0grammConnectorDelegate: class {
    func didReceiveData()
}

protocol LoginDelegate: class {
    func didLogin(successful: Bool)
    func didReceiveCaptcha(image: UIImage)
}

extension String {
    func base64ToImage() -> UIImage? {
        if let url = URL(string: self),let data = try? Data(contentsOf: url),let image = UIImage(data: data) {
            return image
        }
        return nil
    }
}

enum Flags: Int {
    case sfw = 9
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

class Pr0grammConnector {

    weak var delegate: Pr0grammConnectorDelegate?
    weak var loginDelegate: LoginDelegate?

    let http = "https://"
    let thumb = "thumb."
    let img = "img."
    let vid = "vid."
    let baseURL = "pr0gramm.com/"
    let top = "api/items/get?flags=3&promoted=0"
    let itemInfo = "api/items/info?itemId="
    var responseModels: [AllItems?] = []
    var captchaResponse: Login?
    var nonce: String?
    
    var allItems: [Item] {
        var items = [Item]()
        
        for responseModel in responseModels {
            items += responseModel?.items ?? []
        }
        return items
    }
    
    var isLoggedIn: Bool {
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
                self.captchaResponse = try jsonDecoder.decode(Login.self, from: data)
                let image = self.captchaResponse?.captcha?.base64ToImage()
                self.loginDelegate?.didReceiveCaptcha(image: image!)
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
        post(data: data, to: url) { success in
            print("Login: \(success)")
            self.loginDelegate?.didLogin(successful: success)
        }
    }
    
    func logout() {
        let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: "https://pr0gramm.com/")!)
        cookies?.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
    }
    
    //"description": "-1 = Minus, 1 = Plus, 2 = Fav, 0 = Kein Vote/Vote zurückziehen",
    func vote(commentId: String, value: Int) {
        guard let nonce = nonce else { return }
        let data: [String: String] = ["id": commentId,
                                            "vote": "\(value)",
                                            "_nonce": nonce]

        let url = URL(string: http + baseURL + "api/comments/vote")!
        post(data: data, to: url) { success in
            print("Voted: \(success)")
        }
    }
    
    private func post(data: [String: String], to url: URL, completion: @escaping (Bool) -> Void) {
        let jsonString = data.reduce("") { "\($0)\($1.0)=\($1.1)&" }
        let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard let data = data else {
                completion(false)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
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
                self.delegate?.didReceiveData()
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
        
    func searchItems(for tags: [String]) {
        clearItems()
        let url = URL(string: "https://pr0gramm.com/api/items/get?flags=3&promoted=1&tags=\(tags[0])")!
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
                self.delegate?.didReceiveData()
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }

    func thumbLink(for indexPath: IndexPath) -> String? {
        guard indexPath.row <= allItems.count - 1 else { return nil }
        let link = http + thumb + baseURL + allItems[indexPath.row].thumb
        return link
    }

    func imageLink(for indexPath: IndexPath) -> String? {
        guard indexPath.row <= allItems.count - 1 else { return nil }
        let link = http + img + baseURL + allItems[indexPath.row].image
        return link
    }

    func imageLink(for item: Item) -> String? {
        guard !item.image.hasSuffix(".mp4") else { return nil }
        let link = http + img + baseURL + item.image
        return link
    }
    
    func videoLink(for item: Item) -> String {
        let link = http + vid + baseURL + item.image
        return link
    }

    func item(for indexPath: IndexPath) -> Item? {
        return allItems[indexPath.row]
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
