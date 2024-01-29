
import Foundation

class Comment: Codable, Equatable {
    
    var depth = 0
	var id: Int = 0
	var parent: Int?
	var content: String = ""
	var created: Int = 0
	var up: Int = 0
	var down: Int = 0
	var confidence: Double = 0
	var name: String = ""
    var mark: Mark = .unbekannt
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(created))
    }

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

    required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(Int.self, forKey: .id)
		parent = try values.decodeIfPresent(Int.self, forKey: .parent)
		content = try values.decode(String.self, forKey: .content)
		created = try values.decode(Int.self, forKey: .created)
		up = try values.decode(Int.self, forKey: .up)
		down = try values.decode(Int.self, forKey: .down)
		confidence = try values.decode(Double.self, forKey: .confidence)
		name = try values.decode(String.self, forKey: .name)
        mark = try values.decode(Mark.self, forKey: .mark)
	}
    
    init(with message: String, name: String, depth: Int) {
        self.depth = depth
        self.up = 1
        self.content = message
        self.name = name
        self.created = Int(Date().timeIntervalSince1970)
    }
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
}
