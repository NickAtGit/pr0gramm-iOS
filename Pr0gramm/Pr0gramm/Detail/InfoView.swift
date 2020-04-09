
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
    
    var itemInfo: ItemInfo? {
        didSet {
            commentsButton.isHidden = itemInfo?.comments.count == 0
        }
    }
    
    var showCommentsAction: (() -> Void)?
    var upvoteAction: (() -> Void)?
    var downvoteAction: (() -> Void)?
    var favoriteAction: (() -> Void)?
    var expandTagsAction: (() -> Void)?

    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var voteButtons: [HapticFeedbackButton]!
    @IBOutlet private var tagsButton: HapticFeedbackButton!
    @IBOutlet private var commentsButton: HapticFeedbackButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        pointsLabel.textColor = .white
        userNameLabel.textColor = .white
    }
    
    @IBAction func upvoteTapped(_ sender: HapticFeedbackButton) {
        vote(.upvote)
        changeSelectedStateFor(button: sender)
        upvoteAction?()
    }
    
    @IBAction func favoriteTapped(_ sender: HapticFeedbackButton) {
        vote(.favorite)
        changeSelectedStateFor(button: sender)
        favoriteAction?()
    }
    
    @IBAction func downvoteTapped(_ sender: HapticFeedbackButton) {
        vote(.downvote)
        changeSelectedStateFor(button: sender)
        downvoteAction?()
    }
    
    @IBAction func expandTagsTapped(_ sender: Any) {
        expandTagsAction?()
    }
    
    @IBAction func showCommentsTapped(_ sender: Any) {
        showCommentsAction?()
    }
    
    private func vote(_ vote: Vote) {
        guard let item = item else { return }
        pr0grammConnector?.vote(itemId: "\(item.id)", value: vote.rawValue)
    }
    
    private func changeSelectedStateFor(button: HapticFeedbackButton) {
        voteButtons.forEach { $0 === button ? ($0.imageView?.tintColor = .green) : ($0.imageView?.tintColor = nil )}
    }
}
