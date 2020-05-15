
import Foundation

struct CommentsLikes: Codable {
	let id: Int
	let up: Int
	let down: Int
	let content: String
	let created: Int
	let ccreated: Int
	let itemId: Int
	let thumb: String
	let userId: Int
	let mark: Int
	let name: String

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case up = "up"
		case down = "down"
		case content = "content"
		case created = "created"
		case ccreated = "ccreated"
		case itemId = "itemId"
		case thumb = "thumb"
		case userId = "userId"
		case mark = "mark"
		case name = "name"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(Int.self, forKey: .id)
		up = try values.decode(Int.self, forKey: .up)
		down = try values.decode(Int.self, forKey: .down)
		content = try values.decode(String.self, forKey: .content)
		created = try values.decode(Int.self, forKey: .created)
		ccreated = try values.decode(Int.self, forKey: .ccreated)
		itemId = try values.decode(Int.self, forKey: .itemId)
		thumb = try values.decode(String.self, forKey: .thumb)
		userId = try values.decode(Int.self, forKey: .userId)
		mark = try values.decode(Int.self, forKey: .mark)
		name = try values.decode(String.self, forKey: .name)
	}
}
