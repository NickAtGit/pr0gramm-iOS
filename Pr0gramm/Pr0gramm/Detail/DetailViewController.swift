
import UIKit
import AVFoundation
import ScrollingContentViewController
import AVKit
import GTForceTouchGestureRecognizer

class DetailViewController: ScrollingContentViewController, StoryboardInitialViewController {

    weak var coordinator: Coordinator?
    var pr0grammConnector: Pr0grammConnector!

    private var stackView: UIStackView!
    private let imageView = TapableImageView()
    private let tagsCollectionViewController = TagsCollectionViewController.fromStoryboard()
    private let commentsStackView = UIStackView()
    private let infoView = InfoView.instantiateFromNib()
    private var avPlayer: AVPlayer?
    private var avPlayerViewController: AVPlayerViewController?
    private let loadCommentsButton = UIButton()

    var item: Item? {
        didSet {
            guard let item = item else { return }
            pr0grammConnector.loadItemInfo(for: item.id) { self.itemInfo = $0; self.setupTags() }
            updateUI()
        }
    }
    
    private var itemInfo: ItemInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showImageDetail),
                                               name: Notification.Name("showImageDetail"),
                                               object: nil)
        
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .top
        commentsStackView.axis = .vertical
        commentsStackView.spacing = 20
                
        tagsCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(tagsCollectionViewController)
        
        loadCommentsButton.setTitle("Kommentare anzeigen", for: .normal)
        loadCommentsButton.addTarget(self, action: #selector(showComments), for: .touchUpInside)

        stackView = UIStackView(arrangedSubviews: [imageView,
                                                   infoView,
                                                   tagsCollectionViewController.view,
                                                   loadCommentsButton,
                                                   commentsStackView])
        
        tagsCollectionViewController.didMove(toParent: self)

        stackView.spacing = 20
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

        let hostView = UIView()
        hostView.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: hostView.topAnchor, constant: 2).isActive = true
        stackView.leftAnchor.constraint(equalTo: hostView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: hostView.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: hostView.bottomAnchor).isActive = true
        
        contentView = hostView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        let forceTouchGestureRecognizer = GTForceTouchGestureRecognizer(target: self, action: #selector(upVote))
        view.addGestureRecognizer(forceTouchGestureRecognizer)
    }
    
    @objc
    func upVote() {
        guard let id = item?.id else { return }
        pr0grammConnector?.vote(itemId: "\(id)", value: 1)
        let navigationContoller = self.navigationController as! NavigationController
        navigationContoller.showBanner(with: "Han blussert ⨁")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avPlayer?.pause()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }
    
    @objc
    func showImageDetail(_ notificaiton: NSNotification) {
        guard (notificaiton.object as? TapableImageView) == imageView else { return }
        guard let image = imageView.image else { return }
        coordinator?.showImageViewController(with: image, from: self)
    }
    
    @objc
    func play() {
        avPlayer?.play()
    }
    
    func stop() {
        avPlayer?.pause()
    }
        
    private func updateUI() {
        avPlayer?.pause()
        guard let item = item else { return }
        imageView.heightAnchor.constraint(equalTo: view.widthAnchor,
                                          multiplier: CGFloat(item.height) / CGFloat(item.width)).isActive = true
        infoView.pointsLabel.text = "\(item.up - item.down)"
        infoView.userNameLabel.text = item.user
                

        if let link = pr0grammConnector.imageLink(for: item) {
            imageView.downloadedFrom(link: link)
        } else {
            
            avPlayer = AVPlayer()
            avPlayerViewController = AVPlayerViewController()
            guard let avPlayer = avPlayer else { return }
            guard let avPlayerViewController = avPlayerViewController else { return }

            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(DetailViewController.playerItemDidReachEnd(_:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: avPlayer.currentItem)

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
    }
    
    private func setupTags() {
        guard let itemInfo = itemInfo else { return }
        DispatchQueue.main.async {
            self.tagsCollectionViewController.tags = itemInfo.tags
        }
    }
    
    @objc
    func showComments() {
        guard let itemInfo = itemInfo else { return }
        self.addComments(for: itemInfo)
        loadCommentsButton.isHidden = true
    }
    
    private func addComments(for itemInfo: ItemInfo) {
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
            if playerItem == avPlayer?.currentItem {
                playerItem.seek(to: CMTime.zero, completionHandler: nil)
                avPlayer?.play()
            }
        }
    }
}
