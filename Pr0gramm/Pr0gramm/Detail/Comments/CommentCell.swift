
import UIKit

protocol CommentCellDelegate: class {
    func didPostReply(for comment: Comment)
}

class CommentCell: UITableViewCell, UIContextMenuInteractionDelegate {
    
    var detailViewModel: DetailViewModel!
    weak var delegate: CommentCellDelegate?
    
    @IBOutlet private var messageTextView: UITextView!
    @IBOutlet private var authorLabel: UILabel!
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var opLabel: OPLabel!
    @IBOutlet private var leadingConstraint: NSLayoutConstraint!
    
    private let feedback = UISelectionFeedbackGenerator()
    private var initialPointCount = 0
    
    var comment: Comment! {
        didSet {
            authorLabel.text = comment.name
            messageTextView.text = comment.content
            initialPointCount =  comment.up - comment.down
            pointsLabel.text = "\(initialPointCount)"
            opLabel.isHidden = !detailViewModel.isAuthorOP(for: comment)
            leadingConstraint.constant = leadingConstraint.constant + CGFloat(comment.depth * 15)
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
        
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        isUserInteractionEnabled = true
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            return self.createContextMenu()
        }
    }
    
    func createContextMenu() -> UIMenu {
        
        let upvoteAction = UIAction(title: "Plus", image: UIImage(systemName: "plus.circle")) { [unowned self] _ in
            self.upvoteTapped()
        }
        
        let downvoteAction = UIAction(title: "Minus", image: UIImage(systemName: "minus.circle")) { [unowned self] _ in
            self.downVoteTapped()
        }
        
        let favoriteAction = UIAction(title: "Favorit", image: UIImage(systemName: "heart")) { [unowned self] _ in
            self.favoriteTapped()
        }
        
        let voteMenu = UIMenu(title: "Vote", image: UIImage(systemName: "star.circle"), children: [upvoteAction,downvoteAction,favoriteAction])
        
        let shrugAction = UIAction(title: "¯\\_(ツ)_/¯", image: UIImage(systemName: "arrowshape.turn.up.left")) { [unowned self] _ in
            self.replyTapped()
        }

        let replyAction = UIAction(title: "Antworten", image: UIImage(systemName: "arrowshape.turn.up.left")) { [unowned self] _ in
            self.replyTapped()
        }
                
        return UIMenu(title: "", children: [shrugAction, replyAction, voteMenu])
    }
    
    func upvoteTapped() {
        guard let comment = comment,
            let id = comment.id else { return }
        detailViewModel.connector.vote(id: id, value: .upvote, type: .voteComment)
        feedback.selectionChanged()
        pointsLabel.text = "\(initialPointCount + 1)"
    }
    
    func downVoteTapped() {
        guard let comment = comment,
            let id = comment.id else { return }
        detailViewModel.connector.vote(id: id, value: .downvote, type: .voteComment)
        feedback.selectionChanged()
        pointsLabel.text = "\(initialPointCount - 1)"
    }
    
    func favoriteTapped() {
        guard let comment = comment,
            let id = comment.id else { return }
        detailViewModel.connector.vote(id: id, value: .favorite, type: .voteComment)
        feedback.selectionChanged()
        pointsLabel.text = "\(initialPointCount + 1)"
    }
    
    func replyTapped() {
        delegate?.didPostReply(for: comment)
//        detailViewModel.connector.postComment(to: detailViewModel.item.value.id, parentId: id, comment: "Nice")
    }
    
    override func prepareForReuse() {
        leadingConstraint.constant = 20
    }
}
