
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
        collectionView.collectionViewLayout = fullscreenLayout
        
        connector.fetchItems(sorting: .top, flags: [.sfw]) { [unowned self] items in
            guard let items = items else { return }
            
            DispatchQueue.main.async {
                self.allItems.append(items)
                self.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? TVCollectionVideoCell {
            cell.play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? TVCollectionVideoCell {
            cell.pause()
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
}


class TVCollectionViewCell: TVCollectionViewFullScreenCell {
    
    @IBOutlet var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = UIImage(systemName: "flame")
    }
}

class TVCollectionVideoCell: TVCollectionViewFullScreenCell {
        
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    var url: URL? {
        didSet {
            player = AVPlayer(url: url!)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bounds
            layer.addSublayer(playerLayer!)
        }
    }
    
    override func prepareForReuse() {
        player = nil
        playerLayer?.removeFromSuperlayer()
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
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
