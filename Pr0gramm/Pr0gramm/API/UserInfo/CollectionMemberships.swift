import Foundation

struct CollectionMemberships: Codable {
    let collections: [CollectionMembership]
}

struct CollectionMembership: Codable {
    let id: Int
    let name: String
    let isDefault: Bool?
}
