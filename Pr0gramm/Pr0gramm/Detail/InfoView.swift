
import UIKit
import Bond

class InfoView: UIView, NibView {
    
    var viewModel: DetailViewModel! {
        didSet {
            viewModel.points.bind(to: pointsLabel.reactive.text)
            viewModel.userName.bind(to: userNameLabel.reactive.text)
            viewModel.isTagsExpandButtonHidden.bind(to: tagsButton.reactive.isHidden)
            let _ = viewModel.isTagsExpanded.observeNext { [weak self] isExpanded in
                self?.tagsButton.setImage(isExpanded ? UIImage(systemName: "tag.fill") : UIImage(systemName: "tag"), for: .normal)
            }
        }
    }
        
    var showCommentsAction: (() -> Void)?
    var upvoteAction: (() -> Void)?
    var downvoteAction: (() -> Void)?
    var favoriteAction: (() -> Void)?

    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var voteButtons: [HapticFeedbackButton]!
    @IBOutlet private var tagsButton: HapticFeedbackButton!
    @IBOutlet private var commentsButton: HapticFeedbackButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        pointsLabel.textColor = .white
        userNameLabel.textColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
    }
    
    @IBAction func upvoteTapped(_ sender: HapticFeedbackButton) {
        viewModel.vote(.upvote)
        changeSelectedStateFor(button: sender)
        upvoteAction?()
    }
    
    @IBAction func favoriteTapped(_ sender: HapticFeedbackButton) {
        viewModel.vote(.favorite)
        changeSelectedStateFor(button: sender)
        favoriteAction?()
    }
    
    @IBAction func downvoteTapped(_ sender: HapticFeedbackButton) {
        viewModel.vote(.downvote)
        changeSelectedStateFor(button: sender)
        downvoteAction?()
    }
    
    @IBAction func expandTagsTapped(_ sender: Any) {
        viewModel.isTagsExpanded.value = !viewModel.isTagsExpanded.value
    }
    
    @IBAction func showCommentsTapped(_ sender: Any) {
        showCommentsAction?()
    }
    
    private func changeSelectedStateFor(button: HapticFeedbackButton) {
        voteButtons.forEach { $0 === button ? ($0.imageView?.tintColor = .green) : ($0.imageView?.tintColor = nil )}
    }
}
