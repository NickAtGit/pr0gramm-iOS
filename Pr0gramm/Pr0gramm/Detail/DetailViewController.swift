
import UIKit
import AVFoundation
import ScrollingContentViewController
import AVKit

class DetailViewController: ScrollingContentViewController, StoryboardInitialViewController {

    private var stackView: UIStackView!
    private let imageView = TapableImageView()
    private let tagsCollectionViewController = TagsCollectionViewController.fromStoryboard()
    private let commentsStackView = UIStackView()
    private let infoView = InfoView.instantiateFromNib()
    private let avPlayer = AVPlayer()
    private let avPlayerViewController = AVPlayerViewController()
    
    var pr0grammConnector: Pr0grammConnector!
    var item: Item? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .top
        commentsStackView.axis = .vertical
        commentsStackView.spacing = 20
                
        tagsCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(tagsCollectionViewController)

        stackView = UIStackView(arrangedSubviews: [imageView,
                                                   infoView,
                                                   tagsCollectionViewController.view,
                                                   commentsStackView])
        
        tagsCollectionViewController.didMove(toParent: self)

        stackView.spacing = 20
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

        let hostView = UIView()
        hostView.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: hostView.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: hostView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: hostView.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: hostView.bottomAnchor).isActive = true
        
        contentView = hostView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        //Play audio when ringer switch is silent
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avPlayer.pause()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }
    
    @objc
    func play() {
        avPlayer.play()
    }
        
    private func updateUI() {
        avPlayer.pause()
        guard let item = item else { return }
        imageView.heightAnchor.constraint(equalTo: view.widthAnchor,
                                          multiplier: CGFloat(item.height) / CGFloat(item.width)).isActive = true
        infoView.pointsLabel.text = "\(item.up - item.down)"
        infoView.userNameLabel.text = item.user
                
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DetailViewController.playerItemDidReachEnd(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)

        if let link = pr0grammConnector.imageLink(for: item) {
            imageView.downloadedFrom(link: link)
        } else {
            avPlayer.isMuted = false
            avPlayerViewController.player = avPlayer
            avPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = false
            avPlayerViewController.view.heightAnchor.constraint(equalToConstant: view.bounds.width * CGFloat(item.height) / CGFloat(item.width)).isActive = true
            addChild(avPlayerViewController)
            stackView.removeArrangedSubview(imageView)
            stackView.insertArrangedSubview(avPlayerViewController.view, at: 0)
            avPlayerViewController.didMove(toParent: self)
            let link = pr0grammConnector.videoLink(for: item)
            let url = URL(string: link)
            let playerItem = AVPlayerItem(url: url!)
            avPlayer.replaceCurrentItem(with: playerItem)
        }

        pr0grammConnector.loadItemInfo(for: item.id) { itemInfo in
            guard let itemInfo = itemInfo else { return }
            self.addComments(for: itemInfo)
            DispatchQueue.main.async {
                self.tagsCollectionViewController.tags = itemInfo.tags
            }
        }
    }
    
    func addComments(for itemInfo: ItemInfo) {
        for comment in itemInfo.comments {
            DispatchQueue.main.async {
                let commentView = CommentView.instantiateFromNib()
                commentView.pr0grammConnector = self.pr0grammConnector
                commentView.comment = comment
                self.commentsStackView.addArrangedSubview(commentView)
            }
        }
    }
    
    @objc
    func playerItemDidReachEnd(_ notification: NSNotification) {
        if let playerItem = notification.object as? AVPlayerItem {
            if playerItem == avPlayer.currentItem {
                playerItem.seek(to: CMTime.zero, completionHandler: nil)
                avPlayer.play()
            }
        }
    }
}
