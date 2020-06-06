
import Foundation

struct CollectionItem: Codable {
	let id: Int
	let thumb: String

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case thumb = "thumb"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(Int.self, forKey: .id)
		thumb = try values.decode(String.self, forKey: .thumb)
	}
}
