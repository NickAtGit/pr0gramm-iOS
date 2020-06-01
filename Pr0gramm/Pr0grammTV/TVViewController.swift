
import UIKit
import AVFoundation
import TVUIKit
import AVKit

class TVViewController: UIViewController {
    
    fileprivate let fullscreenLayout = TVCollectionViewFullScreenLayout()

    private let connector = Pr0grammConnector()
    @IBOutlet private var collectionView: UICollectionView!
    private var allItems: [AllItems] = []
    
    var items: [Item] {
        var items = [Item]()
        allItems.forEach { items += $0.items }
        return items
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        fullscreenLayout.maskInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.collectionViewLayout = fullscreenLayout
        
        connector.fetchItems(sorting: .neu, flags: [.sfw]) { [unowned self] items in
            guard let items = items else { return }
            
            DispatchQueue.main.async {
                self.allItems.append(items)
                self.collectionView.reloadData()
            }
        }
    }
    
    private func showVideo(for url: URL, delayed: Bool = false) {
        let videoViewController = AVPlayerViewController()
        let player = AVPlayer(url: url)
        videoViewController.player = player
        player.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (delayed ? 1 : 0)) {
            self.present(videoViewController, animated: true)
        }
    }
}

extension TVViewController: TVCollectionViewDelegateFullScreenLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        didCenterCellAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TVCollectionVideoCell,
            let url = cell.url {
            showVideo(for: url, delayed: true)
        }
    }
}

extension TVViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = items[indexPath.row]
        let link = connector.link(for: item)
        if link.link.hasSuffix(".mp4") {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell",
                                                          for: indexPath) as! TVCollectionVideoCell
            cell.url = URL(string: link.link)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tvCell",
                                                          for: indexPath) as! TVCollectionViewCell
            cell.imageView.downloadedFrom(link: link.link)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TVCollectionVideoCell,
            let url = cell.url {
            showVideo(for: url)
        }
    }
}


class TVCollectionViewCell: TVCollectionViewFullScreenCell {
    
    @IBOutlet var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = UIImage(systemName: "flame")
    }
}

class TVCollectionVideoCell: TVCollectionViewFullScreenCell {
    var url: URL?
}


extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }

    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
