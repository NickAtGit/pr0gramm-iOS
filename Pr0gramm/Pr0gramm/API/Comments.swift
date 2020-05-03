
import Foundation

struct Comments : Codable, Equatable {
    var depth = 0
	let id : Int?
	let parent : Int?
	let content : String?
	let created : Int?
	let up : Int
	let down : Int
	let confidence : Double?
	let name : String?
	let mark : Int?

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case parent = "parent"
		case content = "content"
		case created = "created"
		case up = "up"
		case down = "down"
		case confidence = "confidence"
		case name = "name"
		case mark = "mark"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		parent = try values.decodeIfPresent(Int.self, forKey: .parent)
		content = try values.decodeIfPresent(String.self, forKey: .content)
		created = try values.decodeIfPresent(Int.self, forKey: .created)
		up = try values.decode(Int.self, forKey: .up)
		down = try values.decode(Int.self, forKey: .down)
		confidence = try values.decodeIfPresent(Double.self, forKey: .confidence)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		mark = try values.decodeIfPresent(Int.self, forKey: .mark)
	}

}
