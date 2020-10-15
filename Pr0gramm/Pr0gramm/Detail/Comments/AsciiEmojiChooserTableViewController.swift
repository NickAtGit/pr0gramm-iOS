
import UIKit

class AsciiEmojiChooserTableViewController: UITableViewController, Storyboarded {
    
    private let emoji = ["¯\\_(ツ)_/¯",
                         "( ͡° ͜ʖ ͡°)",
                         "(ノ ゜Д゜)ノ ︵ ┻━┻",
                         "┬──┬ ノ(ò_óノ)",
                         "(づ｡◕‿‿◕｡)づ",
                         "ᕙ(⇀‸↼‶)ᕗ",
                         "╰( ͡° ͜ʖ ͡° )つ──☆*:・ﾟ",
                         "༼ つ ◕_◕ ༽つ",
                         "☉ ‿ ⚆",
                         "¯\\_( ͡° ͜ʖ ͡°)_/¯",
                         "ᕕ(⌐■_■)ᕗ ♪♬",
                         "ԅ(≖‿≖ԅ)",
                         "( ͡° ͜ʖ ͡°)ﾉ⌐■-■",
                         "୧༼ಠ益ಠ༽︻╦╤─",
                         "＼(＾O＾)／",
                         "☜(꒡⌓꒡)",
                         "(ಥ﹏ಥ)",
                         "┬┴┬┴┤(･_├┬┴┬┴",
                         "ツ",
                         "( ͡° ʖ̯ ͡°)",
                         "(◔_◔)"]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emoji.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "emojiCell")!
        cell.textLabel?.text = emoji[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIPasteboard.general.string = tableView.cellForRow(at: indexPath)?.textLabel?.text
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        return view
    }
}
