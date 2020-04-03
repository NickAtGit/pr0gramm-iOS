
import UIKit

private let reuseIdentifier = "detailLargeCell"

class DetailCollectionViewController: UICollectionViewController, StoryboardInitialViewController {
    
    weak var coordinator: Coordinator?
    
    let numberOfCellsPerRow: CGFloat = 1
    
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(previousItem),
                                               name: Notification.Name("leftTapped"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(nextItem),
                                               name: Notification.Name("rightTapped"),
                                               object: nil)
        
        let downloadBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(downloadItem))
                
        navigationItem.leftBarButtonItem = downloadBarButtonItem
    }
            
    @objc
    func downloadItem() {
        guard let connector = coordinator?.pr0grammConnector,
            let cell = collectionView.visibleCells.first as? DetailCollectionViewCell,
            let item = cell.detailViewController.item else { return }
        
        let link = connector.imageLink(for: item) ?? connector.videoLink(for: item)
        let downloader = Downloader()
        let url = URL(string: link)!
        downloader.loadFileAsync(url: url) { successfully in
            DispatchQueue.main.async {
                let navigationContoller = self.navigationController as! NavigationController
                navigationContoller.showBanner(with: successfully ? "Download abgeschlossen" : "Download fehlgeschlagen")
            }
        }
    }
    
    @objc
    func nextItem() {
        let cell = collectionView.visibleCells.first!
        let indexPath = collectionView.indexPath(for: cell)!
        let newIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
    }

    
    @objc
    func previousItem() {
        let cell = collectionView.visibleCells.first!
        let indexPath = collectionView.indexPath(for: cell)!
        let newIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        collectionView.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func getCurrentIndex() -> Int {
        return Int(collectionView.contentOffset.x / collectionView.frame.width)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let items = coordinator?.pr0grammConnector.allItems else { return 0 }
        return items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DetailCollectionViewCell
        
        cell.detailViewController = DetailViewController.fromStoryboard()
        cell.detailViewController.coordinator = coordinator
        cell.detailViewController.pr0grammConnector = coordinator?.pr0grammConnector
        cell.detailViewController.item = coordinator?.pr0grammConnector.item(for: indexPath)
        embed(cell.detailViewController, in: cell.content)
        
        return cell
    }
    
    func scrollTo(indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let items = coordinator?.pr0grammConnector.allItems else { return }

        if indexPath.row + 1 == items.count {
            print("Loading more items")
            coordinator?.pr0grammConnector.fetchItems(sorting: Sorting(rawValue: AppSettings.sorting)!,
                                                      flags: AppSettings.currentFlags, more: true)
        }
    }
}

extension DetailCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width,
                      height: view.frame.height - (view.safeAreaInsets.top + view.safeAreaInsets.bottom))
    }
}

class SnapCenterLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
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
}
