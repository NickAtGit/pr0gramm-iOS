
import UIKit

private let reuseIdentifier = "thumbCell"

class MainCollectionViewController: UICollectionViewController, StoryboardInitialViewController {

    weak var coordinator: Coordinator?
    
    private let numberOfCellsPerRow: CGFloat = 3
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator?.pr0grammConnector.addObserver(self)

        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1) * horizontalSpacing) / numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }

        refreshControl.addTarget(self,
                                 action: #selector(MainCollectionViewController.refresh),
                                 for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        refresh()
    }
    
    deinit {
        coordinator?.pr0grammConnector.removeObserver(self)
    }

    @objc
    func refresh() {
        coordinator?.pr0grammConnector.clearItems()
        coordinator?.pr0grammConnector.fetchItems(sorting: Sorting(rawValue: AppSettings.sorting)!,
                                                  flags: AppSettings.currentFlags)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let items = coordinator?.pr0grammConnector.allItems else { return 0 }
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ThumbCollectionViewCell
        if let link = coordinator?.pr0grammConnector.thumbLink(for: indexPath) {
            cell.imageView.downloadedFrom(link: link)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = coordinator?.pr0grammConnector.item(for: indexPath) else { return }
        coordinator?.showDetail(for: item, at: indexPath)
    }
    

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let items = coordinator?.pr0grammConnector.allItems else { return }

        if indexPath.row + 1 == items.count {
            coordinator?.pr0grammConnector.fetchItems(sorting: Sorting(rawValue: AppSettings.sorting)!,
                                                      flags: AppSettings.currentFlags, more: true)
        }
    }
}

extension MainCollectionViewController: Pr0grammConnectorObserver {
    
    func connectorDidUpdate(type: ConnectorUpdateType) {
        switch type {
        case .login(let success):
            if success { refresh() }
        case .receivedData:
            collectionView?.reloadData()
            refreshControl.endRefreshing()
        case .logout:
            refresh()
        default:
            break
        }
    }
}
