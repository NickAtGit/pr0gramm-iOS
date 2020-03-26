
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
        collectionView.collectionViewLayout = FlowLayout()
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


class FlowLayout: UICollectionViewFlowLayout {
        
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesForElementsInRect = super.layoutAttributesForElements(in: rect)
        var newAttributesForElementsInRect = [UICollectionViewLayoutAttributes]()
        // use a value to keep track of left margin
        var leftMargin: CGFloat = 0.0;
        for attributes in attributesForElementsInRect! {
            let refAttributes = attributes
            // assign value if next row
            if (refAttributes.frame.origin.x == self.sectionInset.left) {
                leftMargin = self.sectionInset.left
            } else {
                // set x position of attributes to current margin
                var newLeftAlignedFrame = refAttributes.frame
                newLeftAlignedFrame.origin.x = leftMargin
                refAttributes.frame = newLeftAlignedFrame
            }
            // calculate new value for current margin
            leftMargin += refAttributes.frame.size.width
            newAttributesForElementsInRect.append(refAttributes)
        }
        return newAttributesForElementsInRect
    }
}
