
import Foundation

struct UserInfo: Codable {
	let user: User
	let comments: [ProfileComments]
	let commentCount: Int
	let commentsLikes: [CommentsLikes]
	let commentLikesCount: Int
	let uploads: [Uploads]
	let uploadCount: Int
	let likesArePublic: Bool
    let collections: [Collections]?
	let tagCount: Int
	let badges: [Badges]
	let followCount: Int
	let appLinks: [String]
	let following: Bool
	let subscribed: Bool
	let ts: Int
	let cache: String?
	let rt: Int
	let qc: Int

	enum CodingKeys: String, CodingKey {
		case user = "user"
		case comments = "comments"
		case commentCount = "commentCount"
		case commentsLikes = "comments_likes"
		case commentLikesCount = "commentLikesCount"
		case uploads = "uploads"
		case uploadCount = "uploadCount"
		case likesArePublic = "likesArePublic"
		case collections = "collections"
		case tagCount = "tagCount"
		case badges = "badges"
		case followCount = "followCount"
		case appLinks = "appLinks"
		case following = "following"
		case subscribed = "subscribed"
		case ts = "ts"
		case cache = "cache"
		case rt = "rt"
		case qc = "qc"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		user = try values.decode(User.self, forKey: .user)
		comments = try values.decode([ProfileComments].self, forKey: .comments)
		commentCount = try values.decode(Int.self, forKey: .commentCount)
		commentsLikes = try values.decode([CommentsLikes].self, forKey: .commentsLikes)
		commentLikesCount = try values.decode(Int.self, forKey: .commentLikesCount)
		uploads = try values.decode([Uploads].self, forKey: .uploads)
		uploadCount = try values.decode(Int.self, forKey: .uploadCount)
		likesArePublic = try values.decode(Bool.self, forKey: .likesArePublic)
		collections = try values.decodeIfPresent([Collections].self, forKey: .collections)
		tagCount = try values.decode(Int.self, forKey: .tagCount)
		badges = try values.decode([Badges].self, forKey: .badges)
		followCount = try values.decode(Int.self, forKey: .followCount)
		appLinks = try values.decode([String].self, forKey: .appLinks)
		following = try values.decode(Bool.self, forKey: .following)
		subscribed = try values.decode(Bool.self, forKey: .subscribed)
		ts = try values.decode(Int.self, forKey: .ts)
		cache = try values.decodeIfPresent(String.self, forKey: .cache)
		rt = try values.decode(Int.self, forKey: .rt)
		qc = try values.decode(Int.self, forKey: .qc)
	}
}
