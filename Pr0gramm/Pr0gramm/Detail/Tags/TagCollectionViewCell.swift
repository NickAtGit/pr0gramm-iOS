
import UIKit

class TagCollectionViewCell: UICollectionViewCell, UIContextMenuInteractionDelegate {
    
    var connector: Pr0grammConnector?
    var tags: Tags? {
        didSet {
            tagLabel.text = tags?.tag
            tagLabel.sizeToFit()
        }
    }
    
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var containerView: UIView!
    private let feedback = UISelectionFeedbackGenerator()

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = #colorLiteral(red: 0.1647058824, green: 0.1803921569, blue: 0.1921568627, alpha: 1)
        containerView.layer.cornerRadius = tagLabel.intrinsicContentSize.height / 2
        containerView.clipsToBounds = true
        tagLabel.textColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)

        let interaction = UIContextMenuInteraction(delegate: self)
        containerView.addInteraction(interaction)
        containerView.isUserInteractionEnabled = true
    }
        
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            return self.createContextMenu()
        }
    }
    
    func createContextMenu() -> UIMenu {
        let upvoteAction = UIAction(title: "Plus", image: UIImage(systemName: "plus.circle")) { [unowned self] _ in
            guard let id = self.tags?.id else { return }
            self.connector?.vote(id: id, value: .upvote, type: .voteTag)
        }
        
        let downvoteAction = UIAction(title: "Minus", image: UIImage(systemName: "minus.circle")) { [unowned self] _ in
            guard let id = self.tags?.id else { return }
            self.connector?.vote(id: id, value: .downvote, type: .voteTag)
        }
        
        let saveAction = UIAction(title: "Speichern", image: UIImage(systemName: "text.append")) { [unowned self] _ in
            guard let text = self.tagLabel.text else { return }
            AppSettings.latestSearchStrings = [text] + AppSettings.latestSearchStrings
        }

                
        return UIMenu(title: "", children: [upvoteAction, downvoteAction, saveAction])
    }
}
