
import UIKit
import AVFoundation
import TVUIKit
import AVKit

class TVViewController: UIViewController {
    
    private let fullscreenLayout = TVCollectionViewFullScreenLayout()
    let viewModel = TVViewModel()
    @IBOutlet private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        fullscreenLayout.maskInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.collectionViewLayout = fullscreenLayout
        loadItems()
    }
    
    func loadItems(more: Bool = false, isRefresh: Bool = false) {
        viewModel.loadItems(more: more, isRefresh: isRefresh) { [unowned self] success in
            DispatchQueue.main.async {
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
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TVVideoCollectionCell,
            let url = cell.item?.url {
            cell.prepareToPlay()
            showVideo(for: url, delayed: true)
        }
    }
}

extension TVViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = viewModel.items[indexPath.row]
        if item.isVideo {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell",
                                                          for: indexPath) as! TVVideoCollectionCell
            cell.item = item
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tvCell",
                                                          for: indexPath) as! TVImageCollectionViewCell
            cell.item = item
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TVVideoCollectionCell,
            let url = cell.item?.url {
            showVideo(for: url)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == viewModel.items.count - 1 {
            loadItems(more: true)
            print("Loading more items")
        }
    }
}


class TVImageCollectionViewCell: TVCollectionViewFullScreenCell {
    
    var item: Item? {
        didSet {
            guard let item = item else { return }
            imageView.downloadedFrom(url: item.url)
        }
    }
    @IBOutlet private var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = UIImage(systemName: "flame")
    }
}

class TVVideoCollectionCell: TVCollectionViewFullScreenCell {

    var item: Item?
    @IBOutlet private var imageView: UIImageView!
    
    func prepareToPlay() {
        UIView.transition(with: imageView, duration: 1, options: .transitionCrossDissolve, animations: {
            self.imageView.image = UIImage(systemName: "video.circle.fill")
        })
    }
    
    override func prepareForReuse() {
        imageView.image = UIImage(systemName: "video.circle")
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
