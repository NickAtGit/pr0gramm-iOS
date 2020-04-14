
import UIKit

class CommentCell: UITableViewCell {
    
    var pr0grammConnector: Pr0grammConnector?
    
    @IBOutlet var messageTextView: UITextView!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    let feedback = UISelectionFeedbackGenerator()
    var comment: Comments! {
        didSet {
            authorLabel.text = comment.name
            messageTextView.text = comment.content
            let points = comment.up - comment.down
            pointsLabel.text = "\(points)"

            if comment.parent != 0 {
                leadingConstraint.constant = leadingConstraint.constant + 15
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        messageTextView.textColor = .white
        authorLabel.textColor = .lightGray
        pointsLabel.textColor = #colorLiteral(red: 0.9333333333, green: 0.3019607843, blue: 0.1803921569, alpha: 1)
        messageTextView.isScrollEnabled = false
        messageTextView.backgroundColor = .clear
        messageTextView.textContainerInset = .zero
        messageTextView.textContainer.lineFragmentPadding = 0
    }
    
    @IBAction func upvoteTapped(_ sender: Any) {
        guard let comment = comment,
            let id = comment.id else { return }
        pr0grammConnector?.vote(commentId: "\(id)", value: 1)
        feedback.selectionChanged()
    }
    
    @IBAction func downVoteTapped(_ sender: Any) {
        guard let comment = comment,
            let id = comment.id else { return }
        pr0grammConnector?.vote(commentId: "\(id)", value: -1)
        feedback.selectionChanged()
    }
    
    override func prepareForReuse() {
        leadingConstraint.constant = 20
    }
}
