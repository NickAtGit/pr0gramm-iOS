
import Foundation

struct ProfileComments: Codable {
	let id: Int
	let up: Int
	let down: Int
	let content: String
	let created: Int
	let itemId: Int
	let thumb: String

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case up = "up"
		case down = "down"
		case content = "content"
		case created = "created"
		case itemId = "itemId"
		case thumb = "thumb"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(Int.self, forKey: .id)
		up = try values.decode(Int.self, forKey: .up)
		down = try values.decode(Int.self, forKey: .down)
		content = try values.decode(String.self, forKey: .content)
		created = try values.decode(Int.self, forKey: .created)
		itemId = try values.decode(Int.self, forKey: .itemId)
		thumb = try values.decode(String.self, forKey: .thumb)
	}
}
