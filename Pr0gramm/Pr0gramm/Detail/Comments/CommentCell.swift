
import UIKit

class CommentCell: UITableViewCell {
    
    var detailViewModel: DetailViewModel!
    
    @IBOutlet private var messageTextView: UITextView!
    @IBOutlet private var authorLabel: UILabel!
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private var upvoteButton: UIButton!
    @IBOutlet private var downVoteButton: UIButton!
    @IBOutlet private var favoriteButton: UIButton!
    
    private let feedback = UISelectionFeedbackGenerator()
    private var initialPointCount = 0
    
    var comment: Comments! {
        didSet {
            authorLabel.text = comment.name
            messageTextView.text = comment.content
            initialPointCount =  comment.up - comment.down
            pointsLabel.text = "\(initialPointCount)"

            if comment.parent != 0 {
                leadingConstraint.constant = leadingConstraint.constant + 20
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        messageTextView.isScrollEnabled = false
        messageTextView.backgroundColor = .clear
        messageTextView.textContainerInset = .zero
        messageTextView.textContainer.lineFragmentPadding = 0
        authorLabel.textColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
        pointsLabel.textColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
    }
    
    @IBAction func upvoteTapped(_ sender: Any) {
        guard let comment = comment,
            let id = comment.id else { return }
        detailViewModel.connector.vote(id: id, value: .upvote, type: .voteComment)
        feedback.selectionChanged()
        upvoteButton.imageView?.tintColor = .green
        downVoteButton.imageView?.tintColor = nil
        pointsLabel.text = "\(initialPointCount + 1)"
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
    
    @IBAction func downVoteTapped(_ sender: Any) {
        guard let comment = comment,
            let id = comment.id else { return }
        detailViewModel.connector.vote(id: id, value: .downvote, type: .voteComment)
        feedback.selectionChanged()
        upvoteButton.imageView?.tintColor = nil
        downVoteButton.imageView?.tintColor = .red
        pointsLabel.text = "\(initialPointCount - 1)"
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        guard let comment = comment,
            let id = comment.id else { return }
        detailViewModel.connector.vote(id: id, value: .favorite, type: .voteComment)
        feedback.selectionChanged()
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        upvoteButton.imageView?.tintColor = nil
        downVoteButton.imageView?.tintColor = nil
        pointsLabel.text = "\(initialPointCount + 1)"
    }
    
    override func prepareForReuse() {
        leadingConstraint.constant = 20
        upvoteButton.imageView?.tintColor = nil
        downVoteButton.imageView?.tintColor = nil
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
    }
}
