
import Foundation

struct LoginCaptcha : Codable {
    
    let token : String?
    let captcha : String?
    let ts : Int?
    let cache : String?
    let rt : Int?
    let qc : Int?

    enum CodingKeys: String, CodingKey {

        case token = "token"
        case captcha = "captcha"
        case ts = "ts"
        case cache = "cache"
        case rt = "rt"
        case qc = "qc"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        token = try values.decodeIfPresent(String.self, forKey: .token)
        captcha = try values.decodeIfPresent(String.self, forKey: .captcha)
        ts = try values.decodeIfPresent(Int.self, forKey: .ts)
        cache = try values.decodeIfPresent(String.self, forKey: .cache)
        rt = try values.decodeIfPresent(Int.self, forKey: .rt)
        qc = try values.decodeIfPresent(Int.self, forKey: .qc)
    }

}
