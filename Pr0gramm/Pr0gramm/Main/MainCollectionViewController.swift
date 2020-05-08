
import UIKit

private let reuseIdentifier = "thumbCell"

class PostsOverviewCollectionViewController: UICollectionViewController, StoryboardInitialViewController {

    weak var coordinator: Coordinator?
    var connector: Pr0grammConnector?
    var items: [Item]?
    var isSearch = false
    var didReachEndAction: (() -> Void)?
    
    private let numberOfCellsPerRow: CGFloat = 3
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInsetAdjustmentBehavior = .always

        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1) * horizontalSpacing) / numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }

        if !isSearch {
            refreshControl.addTarget(self,
                                     action: #selector(PostsOverviewCollectionViewController.refresh),
                                     for: .valueChanged)
            collectionView?.refreshControl = refreshControl
            refresh()
        }
        
        updateTabBarItem(for: Sorting(rawValue: AppSettings.sorting)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        connector?.addObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        connector?.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func updateTabBarItem(for sorting: Sorting) {
        
        guard !isSearch else { return }
        tabBarItem = nil
        
        switch sorting {
        case .top:
            title = "Top"
            tabBarItem = UITabBarItem(title: "Top",
                                      image: UIImage(systemName: "circle.grid.3x3"),
                                      selectedImage: UIImage(systemName: "circle.grid.3x3.fill"))
        case .neu:
            title = "Neu"
            tabBarItem = UITabBarItem(title: "Neu",
                                      image: UIImage(systemName: "circle.grid.3x3"),
                                      selectedImage: UIImage(systemName: "circle.grid.3x3.fill"))
        }
    }

    @objc
    func refresh() {
        connector?.clearItems()
        connector?.fetchItems(sorting: Sorting(rawValue: AppSettings.sorting)!,
                                                  flags: AppSettings.currentFlags)
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThumbCollectionViewCell
        guard let item = items?[indexPath.row] else { return cell }

        if let link = connector?.thumbLink(for: item) {
            cell.imageView.downloadedFrom(link: link)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let items = items else { return }
        coordinator?.showDetail(from: self, with: items, at: indexPath, isSearch: isSearch)
    }
    

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !isSearch {
            guard let items = items else { return }
            if indexPath.row == items.count {
                connector?.fetchItems(sorting: Sorting(rawValue: AppSettings.sorting)!,
                                      flags: AppSettings.currentFlags,
                                      more: true)
            }
        }
    }
}

extension PostsOverviewCollectionViewController: Pr0grammConnectorObserver {
    
    func connectorDidUpdate(type: ConnectorUpdateType) {
        switch type {
        case .login(let success):
            if success { refresh() }
        case .receivedData(let newItems):
            items = newItems
            collectionView?.reloadData()
            refreshControl.endRefreshing()
        case .logout:
            refresh()
        default:
            break
        }
    }
}
