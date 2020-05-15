
import Foundation

struct AllItems: Codable {
	let atEnd: Bool
	let atStart: Bool
	let error: String?
	let items: [Item]
	let ts: Int
	let cache: String
	let rt: Int
	let qc: Int

	enum CodingKeys: String, CodingKey {
		case atEnd = "atEnd"
		case atStart = "atStart"
		case error = "error"
		case items = "items"
		case ts = "ts"
		case cache = "cache"
		case rt = "rt"
		case qc = "qc"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		atEnd = try values.decode(Bool.self, forKey: .atEnd)
		atStart = try values.decode(Bool.self, forKey: .atStart)
		error = try values.decodeIfPresent(String.self, forKey: .error)
		items = try values.decode([Item].self, forKey: .items)
		ts = try values.decode(Int.self, forKey: .ts)
		cache = try values.decode(String.self, forKey: .cache)
		rt = try values.decode(Int.self, forKey: .rt)
		qc = try values.decode(Int.self, forKey: .qc)
	}
}
