
import UIKit
import Bond

class InfoView: UIView, NibView {
    
    var viewModel: DetailViewModel! {
        didSet {
            viewModel.points.bind(to: pointsLabel.reactive.text)
            viewModel.userName.bind(to: userNameLabel.reactive.text)
            viewModel.isTagsExpandButtonHidden.bind(to: tagsButton.reactive.isHidden)
            viewModel.isCommentsButtonHidden.bind(to: commentsButton.reactive.isHidden)
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
    @IBOutlet private var upvoteButton: HapticFeedbackButton!
    @IBOutlet private var downvoteButton: HapticFeedbackButton!
    @IBOutlet private var favoriteButton: HapticFeedbackButton!
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
        upvoteAction?()
        pointsLabel.text = "\(viewModel.initialPointCount + 1)"
        upvoteButton.imageView?.tintColor = .green
        favoriteButton.imageView?.tintColor = nil
        downvoteButton.imageView?.tintColor = nil
    }
    
    @IBAction func favoriteTapped(_ sender: HapticFeedbackButton) {
        viewModel.vote(.favorite)
        favoriteAction?()
        pointsLabel.text = "\(viewModel.initialPointCount + 1)"
        upvoteButton.imageView?.tintColor = nil
        favoriteButton.imageView?.tintColor = .red
        downvoteButton.imageView?.tintColor = nil
    }
    
    @IBAction func downvoteTapped(_ sender: HapticFeedbackButton) {
        viewModel.vote(.downvote)
        downvoteAction?()
        pointsLabel.text = "\(viewModel.initialPointCount - 1)"
        upvoteButton.imageView?.tintColor = nil
        favoriteButton.imageView?.tintColor = nil
        downvoteButton.imageView?.tintColor = .red
    }
    
    @IBAction func expandTagsTapped(_ sender: Any) {
        viewModel.isTagsExpanded.value = !viewModel.isTagsExpanded.value
    }
    
    @IBAction func showCommentsTapped(_ sender: Any) {
        showCommentsAction?()
    }
}
