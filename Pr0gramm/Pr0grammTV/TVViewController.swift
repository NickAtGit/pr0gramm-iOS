
import UIKit
import AVFoundation
import TVUIKit
import AVKit

class TVViewController: UIViewController, Storyboarded {
    
    var viewModel: TVViewModel!

    private let fullscreenLayout = TVCollectionViewFullScreenLayout()
    @IBOutlet private var collectionView: UICollectionView!
    let voteImageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        fullscreenLayout.maskInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.collectionViewLayout = fullscreenLayout
        loadItems()
        
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
        gestureRecognizer.direction = .up
        view.addGestureRecognizer(gestureRecognizer)
        
        voteImageView.image = UIImage(systemName: "plus.circle")
        voteImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(voteImageView)
        view.bringSubviewToFront(voteImageView)
        voteImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        voteImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        voteImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        voteImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        voteImageView.alpha = 0
    }
    
    @objc
    func swipeUp() {
        guard let indexPath = collectionView.indexPathsForVisibleItems.first else { return }
        let item = viewModel.items[indexPath.row]
        viewModel.connector.vote(id: item.id, value: .upvote, type: .voteItem)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.voteImageView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                self.voteImageView.alpha = 0
            }
        }
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


class TVImageCollectionViewCell: TVCollectionViewFullScreenCell, ItemInfoDisplaying {
    
    var item: Item! {
        didSet {
            guard let item = item else { return }
            imageView.downloadedFrom(url: item.url)
            showItemInfo()
        }
    }
    @IBOutlet private var imageView: UIImageView!
    var itemInfoView: UIView!

    override func prepareForReuse() {
        imageView.image = UIImage(systemName: "flame")
        itemInfoView.removeFromSuperview()
    }
}

class TVVideoCollectionCell: TVCollectionViewFullScreenCell, ItemInfoDisplaying {

    var item: Item! {
        didSet {
            showItemInfo()
        }
    }
    @IBOutlet private var imageView: UIImageView!
    var itemInfoView: UIView!
    
    func prepareToPlay() {
        UIView.transition(with: imageView, duration: 1, options: .transitionFlipFromBottom, animations: {
            self.imageView.image = UIImage(systemName: "play.circle")
        })
    }
    
    override func prepareForReuse() {
        imageView.image = UIImage(systemName: "video.circle")
        itemInfoView.removeFromSuperview()
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

protocol ItemInfoDisplaying: class {
    var item: Item! { get set }
    var itemInfoView: UIView! { get set }
}

extension ItemInfoDisplaying where Self: UIView {
    
    func showItemInfo() {
        
        let scoreLabel = UILabel()
        scoreLabel.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        scoreLabel.text = "\(item.score)"
        
        let outerStackView = UIStackView()
        outerStackView.axis = .vertical
        outerStackView.addArrangedSubview(scoreLabel)
        
        let userNameLabel = UILabel()
        userNameLabel.text = item.user
        let userClassView = UserClassDotView()
        userClassView.backgroundColor = Colors.color(for: item.mark)
        userClassView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        userClassView.widthAnchor.constraint(equalToConstant: 20).isActive = true

        let innerStackView = UIStackView()
        innerStackView.spacing = 10
        innerStackView.alignment = .center
        innerStackView.addArrangedSubview(userNameLabel)
        innerStackView.addArrangedSubview(userClassView)
        
        outerStackView.addArrangedSubview(innerStackView)
        addSubview(outerStackView)

        outerStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        outerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true

        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.itemInfoView = outerStackView
    }
}
