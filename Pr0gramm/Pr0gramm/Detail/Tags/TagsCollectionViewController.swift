
import UIKit
import Combine

class TagsCollectionViewController: UICollectionViewController, Storyboarded {
    
    weak var coordinator: Coordinator?
    private var viewHeightConstraint: NSLayoutConstraint?
    private var collectionViewContentHeight: CGFloat = 0
    private var collapsedHeight: CGFloat = 0
    
    var viewModel: DetailViewModel! {
        didSet {
            viewModel.$isTagsExpanded
                .sink { [weak self] isExpanded in
                    self?.setContentHeight(isExpanded: isExpanded)
                }
                .store(in: &subscriptions)
        }
    }
    private var tags: [Tags]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.view.layoutSubviews()
            }
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .center)
        alignedFlowLayout.estimatedItemSize = CGSize(width: 100, height: 30)
        collectionView.collectionViewLayout = alignedFlowLayout
        collapsedHeight = alignedFlowLayout.estimatedItemSize.height * 3 + alignedFlowLayout.minimumLineSpacing * 2
        viewHeightConstraint = view.heightAnchor.constraint(equalToConstant: collapsedHeight)
        viewHeightConstraint?.isActive = true

        viewModel.tags.sink { [weak self] tags in
            self?.tags = tags
        }
        .store(in: &subscriptions)
    }
    
    override func viewDidLayoutSubviews() {
        collectionViewContentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        viewModel.isTagsExpandButtonHidden = !(collectionViewContentHeight > collapsedHeight)
    }
    
    private func setContentHeight(isExpanded: Bool) {
        if isExpanded {
            viewHeightConstraint?.constant = collectionViewContentHeight
        } else {
            viewHeightConstraint?.constant = collectionViewContentHeight < collapsedHeight ? collectionViewContentHeight : collapsedHeight
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCollectionViewCell
        cell.connector = coordinator?.pr0grammConnector
        cell.tags = tags?[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TagCollectionViewCell
        guard let tag = cell.tagLabel.text else { return }
        coordinator?.showSearchResult(for: tag, from: self)
    }
}
