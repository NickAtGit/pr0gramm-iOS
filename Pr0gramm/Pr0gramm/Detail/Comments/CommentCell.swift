
import UIKit

protocol CommentCellDelegate: class {
    func requestedReply(for comment: Comment)
}

class CommentCell: UITableViewCell, UIContextMenuInteractionDelegate {
    
    var detailViewModel: DetailViewModel!
    weak var delegate: CommentCellDelegate?
    
    @IBOutlet private var messageTextView: UITextView!
    @IBOutlet private var authorLabel: UILabel!
    @IBOutlet private var userClassDotView: UserClassDotView!
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var opLabel: BadgeLabel!
    @IBOutlet private var youLabel: BadgeLabel!
    @IBOutlet private var leadingConstraint: NSLayoutConstraint!
    
    private let feedback = UISelectionFeedbackGenerator()
    private var initialPointCount = 0
    
    var comment: Comment! {
        didSet {
            authorLabel.text = comment.name
            messageTextView.text = comment.content
            initialPointCount =  comment.up - comment.down
            pointsLabel.text = "\(initialPointCount)"
            userClassDotView.backgroundColor = Colors.color(for: comment.mark)
            opLabel.isHidden = !detailViewModel.isAuthorOP(for: comment)
            youLabel.isHidden = !detailViewModel.isAuthorUser(for: comment)
            leadingConstraint.constant = leadingConstraint.constant + CGFloat(comment.depth * 15)
            opLabel.style = .op
            youLabel.style = .you
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        messageTextView.isScrollEnabled = false
        messageTextView.backgroundColor = .clear
        messageTextView.textContainerInset = .zero
        messageTextView.textContainer.lineFragmentPadding = 0
        authorLabel.textColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
        pointsLabel.textColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        isUserInteractionEnabled = true
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            return self.createContextMenu()
        }
    }
    
    private func createContextMenu() -> UIMenu {
        
        let upvoteAction = UIAction(title: "Plus", image: UIImage(systemName: "plus.circle")) { [unowned self] _ in
            self.upvoteTapped()
        }
        
        let downvoteAction = UIAction(title: "Minus", image: UIImage(systemName: "minus.circle")) { [unowned self] _ in
            self.downVoteTapped()
        }
        
        let favoriteAction = UIAction(title: "Favorit", image: UIImage(systemName: "heart")) { [unowned self] _ in
            self.favoriteTapped()
        }

        let replyAction = UIAction(title: "Antworten", image: UIImage(systemName: "arrowshape.turn.up.left")) { [unowned self] _ in
            self.replyTapped()
        }
                
        return UIMenu(title: "", children: [replyAction, favoriteAction, downvoteAction, upvoteAction])
    }
    
    private func upvoteTapped() {
        guard let comment = comment else { return }
        detailViewModel.connector.vote(id: comment.id, value: .up, type: .voteComment)
        feedback.selectionChanged()
        pointsLabel.text = "\(initialPointCount + 1)"
    }
    
    private func downVoteTapped() {
        guard let comment = comment else { return }
        detailViewModel.connector.vote(id: comment.id, value: .down, type: .voteComment)
        feedback.selectionChanged()
        pointsLabel.text = "\(initialPointCount - 1)"
    }
    
    private func favoriteTapped() {
        guard let comment = comment else { return }
        detailViewModel.connector.vote(id: comment.id, value: .favorite, type: .voteComment)
        feedback.selectionChanged()
        pointsLabel.text = "\(initialPointCount + 1)"
    }
    
    private func replyTapped() {
        delegate?.requestedReply(for: comment)
    }
    
    override func prepareForReuse() {
        leadingConstraint.constant = 20
    }
}
