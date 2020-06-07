
import UIKit
import Bond

class InfoView: UIView, NibView {
    
    var viewModel: DetailViewModel! {
        didSet {
            viewModel.points.bind(to: pointsLabel.reactive.text)
            viewModel.userName.bind(to: userNameLabel.reactive.text)
            viewModel.isTagsExpandButtonHidden.bind(to: tagsButton.reactive.isHidden)
            viewModel.isCommentsButtonHidden.bind(to: commentsButton.reactive.isHidden)
            viewModel.postTime.bind(to: dateLabel.reactive.text)
            userClassDotView.backgroundColor = Colors.color(for: viewModel.item.value.mark)
            
            let _ = viewModel.isTagsExpanded.observeNext { [weak self] isExpanded in
                self?.tagsButton.setImage(isExpanded ? UIImage(systemName: "tag.fill") : UIImage(systemName: "tag"), for: .normal)
            }
            
            let _ = viewModel.currentVote.observeNext { [unowned self] vote in
                switch vote {
                case .neutral:
                    break
                case .up:
                    self.pointsLabel.text = "\(self.viewModel.initialPointCount + 1)"
                    self.upvoteButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
                    self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    self.downvoteButton.setImage(UIImage(systemName: "minus.circle"), for: .normal)
                case .down:
                    self.pointsLabel.text = "\(self.viewModel.initialPointCount - 1)"
                    self.upvoteButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
                    self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    self.downvoteButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
                case .favorite:
                    self.pointsLabel.text = "\(self.viewModel.initialPointCount + 1)"
                    self.upvoteButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
                    self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    self.downvoteButton.setImage(UIImage(systemName: "minus.circle"), for: .normal)
                }
            }
            
            if let action = ActionsManager.shared.retrieveAction(for: viewModel.item.value.id)?.action,
                let voteAction = VoteAction(rawValue: Int(action)) {
                
                switch voteAction {
                    
                case .itemDown:
                    upvoteButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
                    favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    downvoteButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
                case .itemUp:
                    upvoteButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
                    favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    downvoteButton.setImage(UIImage(systemName: "minus.circle"), for: .normal)
                case .itemFavorite:
                    upvoteButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
                    favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    downvoteButton.setImage(UIImage(systemName: "minus.circle"), for: .normal)
                default:
                    break
                }
            }
        }
    }
    var showReplyAction: (() -> Void)?
    var showCommentsAction: (() -> Void)?
    var upvoteAction: (() -> Void)?
    var downvoteAction: (() -> Void)?
    var favoriteAction: (() -> Void)?
    
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var upvoteButton: HapticFeedbackButton!
    @IBOutlet private var downvoteButton: HapticFeedbackButton!
    @IBOutlet private var favoriteButton: HapticFeedbackButton!
    @IBOutlet private var tagsButton: HapticFeedbackButton!
    @IBOutlet private var commentsButton: HapticFeedbackButton!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var userClassDotView: UserClassDotView!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        let interaction = UIContextMenuInteraction(delegate: self)
        pointsLabel.addInteraction(interaction)
        pointsLabel.isUserInteractionEnabled = true
    }
    
    @IBAction func upvoteTapped(_ sender: HapticFeedbackButton) {
        viewModel.vote(.up)
        upvoteAction?()
    }
    
    @IBAction func favoriteTapped(_ sender: HapticFeedbackButton) {
        viewModel.vote(.favorite)
        favoriteAction?()
    }
    
    @IBAction func downvoteTapped(_ sender: HapticFeedbackButton) {
        viewModel.vote(.down)
        downvoteAction?()
    }
    
    @IBAction func expandTagsTapped(_ sender: Any) {
        viewModel.isTagsExpanded.value = !viewModel.isTagsExpanded.value
    }
    
    @IBAction func showCommentsTapped(_ sender: Any) {
        showCommentsAction?()
    }
    
    @IBAction func replyTapped(_ sender: Any) {
        showReplyAction?()
    }
}


extension InfoView: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            return self.createContextMenu()
        }
    }
    
    func createContextMenu() -> UIMenu {
        let upvoteAction = UIAction(title: "Plus", image: UIImage(systemName: "plus.circle")) { [unowned self] _ in
            self.viewModel.vote(.up)
        }
        
        let favoriteAction = UIAction(title: "Favorit", image: UIImage(systemName: "heart")) { [unowned self] _ in
            self.viewModel.vote(.favorite)
        }

        let downvoteAction = UIAction(title: "Minus", image: UIImage(systemName: "minus.circle")) { [unowned self] _ in
            self.viewModel.vote(.down)
        }
                
        return UIMenu(title: "↑: \(viewModel.upvotes)\n↓: \(viewModel.downvotes)",
                      children: [upvoteAction, favoriteAction, downvoteAction])
    }
}
