
import UIKit

private let reuseIdentifier = "thumbCell"

class PostsOverviewCollectionViewController: UIViewController, StoryboardInitialViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var coordinator: Coordinator?
    var viewModel: PostsOverviewViewModel!
    
    @IBOutlet var collectionView: UICollectionView!
    private let numberOfCellsPerRow: CGFloat = 3
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView?.contentInsetAdjustmentBehavior = .always
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1) * horizontalSpacing) / numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }
        
        refreshControl.addTarget(self,
                                 action: #selector(PostsOverviewCollectionViewController.refresh),
                                 for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUI),
                                               name: Notification.Name("flagsChanged+\(String(describing: self))"),
                                               object: nil)
        updateUI()
    }
    
    @objc
    func updateUI() {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        tabBarItem = nil
        title = viewModel.title
        loadItems(isRefresh: true)
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
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThumbCollectionViewCell
        let item = viewModel.items[indexPath.row]
        cell.imageView.downloadedFrom(link: viewModel.thumbLink(for: item))
        if ActionsManager.shared.retrieveAction(for: item.id)?.seen ?? false {
            cell.imageView.addSeenBadge()
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
