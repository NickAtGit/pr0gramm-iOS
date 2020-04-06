
import Foundation

struct Login : Codable {
	let error : String?
	let success : Bool?
	let ban : String?
	let ts : Int?
	let cache : String?
	let rt : Int?
	let qc : Int?

	enum CodingKeys: String, CodingKey {

		case error = "error"
		case success = "success"
		case ban = "ban"
		case ts = "ts"
		case cache = "cache"
		case rt = "rt"
		case qc = "qc"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		error = try values.decodeIfPresent(String.self, forKey: .error)
		success = try values.decodeIfPresent(Bool.self, forKey: .success)
		ban = try values.decodeIfPresent(String.self, forKey: .ban)
		ts = try values.decodeIfPresent(Int.self, forKey: .ts)
		cache = try values.decodeIfPresent(String.self, forKey: .cache)
		rt = try values.decodeIfPresent(Int.self, forKey: .rt)
		qc = try values.decodeIfPresent(Int.self, forKey: .qc)
	}
}
