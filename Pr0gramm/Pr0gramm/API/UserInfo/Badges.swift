
import Foundation

struct Badges: Codable {
	let link: String
	let image: String
	let description: String
	let created: Int

	enum CodingKeys: String, CodingKey {
		case link = "link"
		case image = "image"
		case description = "description"
		case created = "created"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		link = try values.decode(String.self, forKey: .link)
		image = try values.decode(String.self, forKey: .image)
		description = try values.decode(String.self, forKey: .description)
		created = try values.decode(Int.self, forKey: .created)
	}
}
