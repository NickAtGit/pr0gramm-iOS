
import Foundation

struct ItemInfo: Codable {
	let tags: [Tags]
	let comments: [Comment]
	let ts: Int
	let cache: String
	let rt: Int
	let qc: Int

	enum CodingKeys: String, CodingKey {
		case tags = "tags"
		case comments = "comments"
		case ts = "ts"
		case cache = "cache"
		case rt = "rt"
		case qc = "qc"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		tags = try values.decode([Tags].self, forKey: .tags)
		comments = try values.decode([Comment].self, forKey: .comments)
		ts = try values.decode(Int.self, forKey: .ts)
		cache = try values.decode(String.self, forKey: .cache)
		rt = try values.decode(Int.self, forKey: .rt)
		qc = try values.decode(Int.self, forKey: .qc)
	}
}
