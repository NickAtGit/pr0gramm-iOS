/* 
Copyright (c) 2018 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Comments : Codable {
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
