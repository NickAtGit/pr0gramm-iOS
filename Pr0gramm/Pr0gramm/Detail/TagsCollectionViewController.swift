
import UIKit

class TagsCollectionViewController: UICollectionViewController, StoryboardInitialViewController {
    
    weak var coordinator: Coordinator?
    var viewHeightConstraint: NSLayoutConstraint?
    var isExpanded = false

    var tags: [Tags]? {
        didSet {
            collectionView.reloadData()
            view.layoutSubviews()
        }
    }
    
    private var sortedTags: [Tags]? {
        get {
            return tags?.sorted { $0.confidence! > $1.confidence! }
        }
    }
    
    override func viewDidLayoutSubviews() {
        setContentHeight()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        viewHeightConstraint = view.heightAnchor.constraint(equalToConstant: 105)
        viewHeightConstraint?.isActive = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .center)
        alignedFlowLayout.estimatedItemSize = CGSize(width: 100, height: 30)
        collectionView.collectionViewLayout = alignedFlowLayout
    }
    
    func toggleExpansion() {
        isExpanded = !isExpanded
        setContentHeight()
    }
    
    private func setContentHeight() {
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height

        if isExpanded {
            isExpanded = true
            viewHeightConstraint?.constant = contentHeight
        } else {
            let height: CGFloat = 105
            viewHeightConstraint?.constant = contentHeight < height ? contentHeight : height
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedTags?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCollectionViewCell
        cell.tagLabel.text = sortedTags?[indexPath.row].tag
        cell.tagLabel.sizeToFit()
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TagCollectionViewCell
        guard let tag = cell.tagLabel.text else { return }
        coordinator?.showSearchResult(for: tag, from: self)
    }
}
