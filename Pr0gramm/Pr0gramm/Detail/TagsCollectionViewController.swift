
import UIKit

class TagsCollectionViewController: UICollectionViewController, StoryboardInitialViewController {
    
    weak var coordinator: Coordinator?
    
    let numberOfCellsPerRow: CGFloat = 3
    let refreshControl = UIRefreshControl()
    
    var tags: [Tags]? {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            collectionView.heightAnchor.constraint(equalToConstant: collectionView.contentSize.height).isActive = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
        collectionView.collectionViewLayout = alignedFlowLayout
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCollectionViewCell
        cell.tagLabel.text = tags?[indexPath.row].tag
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
}

extension TagsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let label = UILabel(frame: CGRect.zero)
        label.text = tags?[indexPath.item].tag
        label.sizeToFit()
        return CGSize(width: label.frame.width + 20, height: label.frame.height + 8)
    }
}
