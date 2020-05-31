
import UIKit

class BadgesCollectionViewController: UICollectionViewController, StoryboardInitialViewController {
    
    var viewModel: UserInfoViewModel!
    private var viewHeightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewHeightConstraint = view.heightAnchor.constraint(equalToConstant: 50)
        viewHeightConstraint?.isActive = true
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        collectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        viewHeightConstraint?.constant = collectionView.contentSize.height
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.userInfo?.badges.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "badgeCell", for: indexPath) as! BadgeCollectionViewCell
        cell.badge = viewModel.userInfo?.badges[indexPath.row]
        return cell
    }
}

class BadgeCollectionViewCell: UICollectionViewCell, UIContextMenuInteractionDelegate {
    
    var badge: Badges? {
        didSet {
            guard let badge = badge else { return }
            imageView.downloadedFrom(link: "https://pr0gramm.com/media/badges/" + badge.image)
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    
    override func awakeFromNib() {
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
        let okAction = UIAction(title: "Ok", image: UIImage(systemName: "checkmark.circle")) { _ in }
        return UIMenu(title: badge?.description ?? "", children: [okAction])
    }

}
