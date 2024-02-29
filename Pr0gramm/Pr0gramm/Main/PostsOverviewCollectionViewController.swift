
import UIKit

private let reuseIdentifier = "thumbCell"

class PostsOverviewCollectionViewController: UIViewController, Storyboarded, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var coordinator: Coordinator?
    var viewModel: PostsOverviewViewModel!
    
    @IBOutlet var collectionView: UICollectionView!
    private var numberOfCellsPerRow: CGFloat = CGFloat(AppSettings.postCount)
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView?.contentInsetAdjustmentBehavior = .always
        updateLayout()
        updateUI()

        refreshControl.addTarget(self,
                                 action: #selector(PostsOverviewCollectionViewController.refresh),
                                 for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(flagsDidChange),
                                               name: Notification.Name("flagsChanged"),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if numberOfCellsPerRow != CGFloat(AppSettings.postCount) {
            numberOfCellsPerRow = CGFloat(AppSettings.postCount)
            updateLayout()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let collectionView = collectionView else { return }
        
        coordinator.animate { context in
            collectionView.collectionViewLayout.invalidateLayout()
            self.updateLayout()
        } completion: { _ in
            self.view.layoutSubviews()
        }
    }

    
    private func updateLayout() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1) * horizontalSpacing) / numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }
    }
    
    @objc
    func updateUI() {
        tabBarItem = nil
        title = viewModel.title
        refresh()
        tabBarItem = viewModel.tabBarItem
    }
    
    @objc
    func refresh() {
        loadItems(isRefresh: true)
    }
    
    func loadItems(more: Bool = false, isRefresh: Bool = false) {
        viewModel.loadItems(more: more, isRefresh: isRefresh) { [weak self] success in
            print("Loaded items \(success), count: \(self?.viewModel.items.count ?? 0)")
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThumbCollectionViewCell
        let item = viewModel.items[indexPath.row]
        cell.imageView.downloadedFrom(url: item.thumbURL)
        
        let isSeen = ActionsManager.shared.retrieveAction(for: item.id)?.seen ?? false
        if isSeen {
            cell.imageView.addSeenBadge()
        }
        
        if item.isSticky {
            cell.imageView.addStickyBadge()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        coordinator?.showDetail(from: self, with: viewModel, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.items.count - 1 {
            loadItems(more: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! ThumbCollectionViewCell).imageView.cancelDownload()
    }
    
    @objc
    func flagsDidChange() {
        updateUI()
    }
}

extension PostsOverviewCollectionViewController: Pr0grammConnectorObserver {
    
    func connectorDidUpdate(type: ConnectorUpdateType) {
        switch type {
        case .login(let success):
            if success { loadItems() }
        case .logout:
            loadItems()
        default:
            break
        }
    }
}
