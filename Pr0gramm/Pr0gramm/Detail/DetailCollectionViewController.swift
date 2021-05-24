
import UIKit
import Combine
class DetailCollectionViewController: UICollectionViewController, Storyboarded {
    
    weak var coordinator: Coordinator?
    var isSearch = false
    var viewModel: PostsOverviewViewModel!
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        collectionView.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)

        let layout: UICollectionViewFlowLayout = SnapCenterLayout()
        layout.itemSize = CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 25
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.decelerationRate = .fast
        
        NotificationCenter
            .default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                guard let cell = self?.collectionView.visibleCells.first,
                      let indexPath = self?.collectionView.indexPath(for: cell),
                      indexPath.row != 0 else { return }
                self?.scrollTo(indexPath: indexPath)
            }
            .store(in: &subscriptions)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        coordinator.animate { context in
            self.collectionView.collectionViewLayout.invalidateLayout()
        } completion: { _ in
            let cellSize = CGSize(width: self.view.bounds.width - (self.view.safeAreaInsets.left + self.view.safeAreaInsets.right),
                                  height: self.view.bounds.height - (self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom))
            flowLayout.itemSize = cellSize
            self.view.layoutSubviews()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(previousItem),
                                               name: Notification.Name.leftTapped,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(nextItem),
                                               name: Notification.Name.rightTapped,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
                
    @objc
    func nextItem() {
        guard let cell = collectionView.visibleCells.first,
              let indexPath = collectionView.indexPath(for: cell),
              indexPath.row != viewModel.items.count - 1 else { return }
        let newIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    @objc
    func previousItem() {
        guard let cell = collectionView.visibleCells.first,
              let indexPath = collectionView.indexPath(for: cell),
              indexPath.row != 0 else { return }
        let newIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailLargeCell", for: indexPath) as! DetailCollectionViewCell
        
        guard let connector = coordinator?.pr0grammConnector else { return cell }
        cell.detailViewController = DetailViewController.fromStoryboard()
        cell.detailViewController.viewModel = DetailViewModel(item: viewModel.items[indexPath.row], connector: connector)
        cell.detailViewController.coordinator = coordinator
        embed(cell.detailViewController, in: cell.content)
        
        return cell
    }
    
    func scrollTo(indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        let cell = cell as! DetailCollectionViewCell
        cell.detailViewController.play()
        
        if indexPath.row == viewModel.items.count - 1 {
            loadItems(more: true)
        }
    }
    
    func loadItems(more: Bool = false, isRefresh: Bool = false) {
        viewModel.loadItems(more: more, isRefresh: isRefresh) { [weak self] success in
            guard success else { return }
            print("Loaded items \(success), count: \(self?.viewModel.items.count ?? 0)")
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didEndDisplaying cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        guard let cell = cell as? DetailCollectionViewCell else { return }
        cell.detailViewController.stop()
    }
}

extension DetailCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width - (view.safeAreaInsets.left + view.safeAreaInsets.right),
                      height: view.bounds.height - (view.safeAreaInsets.top + view.safeAreaInsets.bottom))
    }
}

class SnapCenterLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        let parent = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        
        let itemSpace = itemSize.width + minimumInteritemSpacing + minimumLineSpacing
        var currentItemIdx = round(collectionView.contentOffset.x / itemSpace)
                
        let vX = velocity.x
        if vX > 0 {
            currentItemIdx += 1
        } else if vX < 0 {
            currentItemIdx -= 1
        }
        
        let nearestPageOffset = (currentItemIdx * itemSpace)
        return CGPoint(x: nearestPageOffset,
                       y: parent.y)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        collectionView?.bounds.size != newBounds.size
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        guard let flowContext = context as? UICollectionViewFlowLayoutInvalidationContext else {
            return
        }
        flowContext.invalidateFlowLayoutDelegateMetrics = true
        flowContext.invalidateFlowLayoutAttributes = true
        super.invalidateLayout(with: flowContext)
    }
}
