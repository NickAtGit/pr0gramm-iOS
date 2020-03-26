/* 
Copyright (c) 2018 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Item : Codable {
	let id : Int
	let promoted : Int
	let up : Int
	let down : Int
	let created : Int
	let image : String
	let thumb : String
    let fullsize : String
	let width : Int
	let height : Int
	let audio : Bool
	let source : String
	let flags : Int
	let user : String
	let mark : Int

	enum CodingKeys: String, CodingKey {

		case id = "id"
		case promoted = "promoted"
		case up = "up"
		case down = "down"
		case created = "created"
		case image = "image"
		case thumb = "thumb"
		case fullsize = "fullsize"
		case width = "width"
		case height = "height"
		case audio = "audio"
		case source = "source"
		case flags = "flags"
		case user = "user"
		case mark = "mark"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(Int.self, forKey: .id)
		promoted = try values.decode(Int.self, forKey: .promoted)
		up = try values.decode(Int.self, forKey: .up)
		down = try values.decode(Int.self, forKey: .down)
		created = try values.decode(Int.self, forKey: .created)
		image = try values.decode(String.self, forKey: .image)
		thumb = try values.decode(String.self, forKey: .thumb)
		fullsize = try values.decode(String.self, forKey: .fullsize)
		width = try values.decode(Int.self, forKey: .width)
		height = try values.decode(Int.self, forKey: .height)
		audio = try values.decode(Bool.self, forKey: .audio)
		source = try values.decode(String.self, forKey: .source)
		flags = try values.decode(Int.self, forKey: .flags)
		user = try values.decode(String.self, forKey: .user)
		mark = try values.decode(Int.self, forKey: .mark)
	}

}
