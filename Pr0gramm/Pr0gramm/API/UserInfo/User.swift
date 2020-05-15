
import Foundation

struct User: Codable {
	let id: Int
	let name: String
	let registered: Int
	let score: Int
	let up: Int
	let down: Int
	let mark: Int
	let admin: Int
	let banned: Int
	let commentDelete: Int
	let itemDelete: Int
	let inactive: Int

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case name = "name"
		case registered = "registered"
		case score = "score"
		case up = "up"
		case down = "down"
		case mark = "mark"
		case admin = "admin"
		case banned = "banned"
		case commentDelete = "commentDelete"
		case itemDelete = "itemDelete"
		case inactive = "inactive"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(Int.self, forKey: .id)
		name = try values.decode(String.self, forKey: .name)
		registered = try values.decode(Int.self, forKey: .registered)
		score = try values.decode(Int.self, forKey: .score)
		up = try values.decode(Int.self, forKey: .up)
		down = try values.decode(Int.self, forKey: .down)
		mark = try values.decode(Int.self, forKey: .mark)
		admin = try values.decode(Int.self, forKey: .admin)
		banned = try values.decode(Int.self, forKey: .banned)
		commentDelete = try values.decode(Int.self, forKey: .commentDelete)
		itemDelete = try values.decode(Int.self, forKey: .itemDelete)
		inactive = try values.decode(Int.self, forKey: .inactive)
	}
}
