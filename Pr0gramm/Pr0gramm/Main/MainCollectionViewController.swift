
import UIKit

private let reuseIdentifier = "thumbCell"

class MainCollectionViewController: UICollectionViewController, StoryboardInitialViewController {

    weak var coordinator: Coordinator?
    var items: [Item]? {
        didSet {
            collectionView.reloadData()
        }
    }
    var isSearch = false
    private let numberOfCellsPerRow: CGFloat = 3
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1) * horizontalSpacing) / numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }

        if !isSearch {
            refreshControl.addTarget(self,
                                     action: #selector(MainCollectionViewController.refresh),
                                     for: .valueChanged)
            collectionView?.refreshControl = refreshControl
            refresh()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coordinator?.pr0grammConnector.addObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coordinator?.pr0grammConnector.removeObserver(self)
    }

    @objc
    func refresh() {
        coordinator?.pr0grammConnector.clearItems()
        coordinator?.pr0grammConnector.fetchItems(sorting: Sorting(rawValue: AppSettings.sorting)!,
                                                  flags: AppSettings.currentFlags)
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThumbCollectionViewCell
        guard let item = items?[indexPath.row] else { return cell }

        if let link = coordinator?.pr0grammConnector.thumbLink(for: item) {
            cell.imageView.downloadedFrom(link: link)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let items = items else { return }
        coordinator?.showDetail(with: items, at: indexPath, isSearch: isSearch)
    }
    

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !isSearch {
            guard let items = items else { return }
            if indexPath.row + 1 == items.count {
                coordinator?.pr0grammConnector.fetchItems(sorting: Sorting(rawValue: AppSettings.sorting)!,
                                                          flags: AppSettings.currentFlags, more: true)
            }
        }
    }
}

extension MainCollectionViewController: Pr0grammConnectorObserver {
    
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
