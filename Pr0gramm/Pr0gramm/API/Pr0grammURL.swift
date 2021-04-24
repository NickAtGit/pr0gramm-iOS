
import Foundation

enum Pr0grammURL {
    static let base: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "pr0gramm.com"
        return components
    }()
    
    static let thumb: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "thumb.pr0gramm.com"
        return components
    }()
    
    static let img: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "img.pr0gramm.com"
        return components
    }()
    
    static let vid: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "vid.pr0gramm.com"
        return components
    }()

    case login
    case captcha
    case postComment
    case profileInfo
    case itemsGet
    case itemsInfo
    case addTags
    
    var components: URLComponents {
        var compontents = Pr0grammURL.base
        
        switch self {
        case .login:
            compontents.path = "/api/user/login"
        case .captcha:
            compontents.path = "/api/user/captcha"
        case .postComment:
            compontents.path = "/api/comments/post"
        case .profileInfo:
            compontents.path = "/api/profile/info"
        case .itemsGet:
            compontents.path = "/api/items/get"
        case .itemsInfo:
            compontents.path = "/api/items/info"
        case .addTags:
            compontents.path = "/api/tags/add"
        }
        
        return compontents
    }
    
    var url: URL { components.url! }
}
