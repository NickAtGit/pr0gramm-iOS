
import Foundation

struct Collections: Codable {
	let id: Int?
	let name: String?
	let keyword: String?
	let isPublic: Int?
	let isDefault: Int?
	let items: [CollectionItem]?

	enum CodingKeys: String, CodingKey {
		case id = "id"
		case name = "name"
		case keyword = "keyword"
		case isPublic = "isPublic"
		case isDefault = "isDefault"
		case items = "items"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decodeIfPresent(Int.self, forKey: .id)
		name = try values.decodeIfPresent(String.self, forKey: .name)
		keyword = try values.decodeIfPresent(String.self, forKey: .keyword)
		isPublic = try values.decodeIfPresent(Int.self, forKey: .isPublic)
		isDefault = try values.decodeIfPresent(Int.self, forKey: .isDefault)
		items = try values.decodeIfPresent([CollectionItem].self, forKey: .items)
	}
}
