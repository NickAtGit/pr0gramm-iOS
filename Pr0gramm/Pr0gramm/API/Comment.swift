
import Foundation

struct Comment : Codable, Equatable {
    var depth = 0
	var id : Int?
	var parent : Int?
	var content : String?
	var created : Int?
	var up : Int = 0
	var down : Int = 0
	var confidence : Double?
	var name : String?
	var mark : Int?

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
    
    init(with message: String, depth: Int) {
        self.depth = depth
        up = 1
        content = message
        name = "Arschrunzeln"
    }
}
