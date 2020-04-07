
import UIKit

class InfoView: UIView, NibView {
    
    var pr0grammConnector: Pr0grammConnector?
    
    var item: Item? {
        didSet {
            guard let item = item else { return }
            pointsLabel.text = "\(item.up - item.down)"
            userNameLabel.text = item.user
        }
    }
    
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        pointsLabel.textColor = .white
        userNameLabel.textColor = .white
    }
    
    @IBAction func upvoteTapped(_ sender: Any) {
        vote(1)
    }
    
    @IBAction func favoriteTapped(_ sender: Any) {
        vote(2)
    }
    
    @IBAction func downvoteTapped(_ sender: Any) {
        vote(-1)
    }
    
    private func vote(_ vote: Int) {
        guard let item = item else { return }
        pr0grammConnector?.vote(itemId: "\(item.id)", value: vote)
    }
}
