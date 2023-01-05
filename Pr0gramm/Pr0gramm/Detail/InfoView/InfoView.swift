
import UIKit
import Combine

class InfoView: UIView, NibView {
    
    private var subscriptions = Set<AnyCancellable>()
    
    var viewModel: DetailViewModel! {
        didSet {
            viewModel.$points
                .assign(to: \.text, on: pointsLabel)
                .store(in: &subscriptions)
            
            userNameButton.setTitle(viewModel.userName, for: .normal)
            
            viewModel.$isTagsExpandButtonHidden
                .assign(to: \.isHidden, on: tagsButton)
                .store(in: &subscriptions)
            
            viewModel.$isCommentsButtonHidden
                .assign(to: \.isHidden, on: commentsButton)
                .store(in: &subscriptions)

            viewModel.$postTime
                .assign(to: \.text, on: dateLabel)
                .store(in: &subscriptions)
            
            userClassDotView.backgroundColor = Colors.color(for: viewModel.item.mark)
            
            
            viewModel.$isTagsExpanded.sink { [weak self] isExpanded in
                self?.tagsButton.setImage(isExpanded ? UIImage(systemName: "tag.fill") : UIImage(systemName: "tag"), for: .normal)
            }
            .store(in: &subscriptions)
            
            viewModel.$currentVote
                .sink { [weak self] vote in
                    guard let self else { return }
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
                .store(in: &subscriptions)
            
            if let action = ActionsManager.shared.retrieveAction(for: viewModel.item.id)?.action,
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
    var showReplyAction: ActionClosure?
    var showCommentsAction: ActionClosure?
    var upvoteAction: ActionClosure?
    var downvoteAction: ActionClosure?
    var favoriteAction: ActionClosure?
    var showUserAction: ((String) -> Void)?
    
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var userNameButton: UIButton!
    @IBOutlet private var upvoteButton: HapticFeedbackButton!
    @IBOutlet private var downvoteButton: HapticFeedbackButton!
    @IBOutlet private var favoriteButton: HapticFeedbackButton!
    @IBOutlet private var tagsButton: HapticFeedbackButton!
    @IBOutlet private var addTagsButton: HapticFeedbackButton!
    @IBOutlet private var commentsButton: HapticFeedbackButton!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var userClassDotView: UserClassDotView!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
        let interaction = UIContextMenuInteraction(delegate: self)
        pointsLabel.addInteraction(interaction)
        pointsLabel.isUserInteractionEnabled = true
    }
    
    @IBAction func userNameTapped(_ sender: UIButton) {
        guard let name = sender.titleLabel?.text else { return }
        showUserAction?(name)
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
        viewModel.isTagsExpanded.toggle()
    }
    
    @IBAction func addTagsTapped(_ sender: Any) {
        viewModel.addTagsButtonTap.send(true)
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
        
        let title = viewModel.shouldShowPoints ? "↑: \(viewModel.upvotes)\n↓: \(viewModel.downvotes)" : "Versteckt"
        
        return UIMenu(title: title,
                      children: [upvoteAction, favoriteAction, downvoteAction])
    }
}
