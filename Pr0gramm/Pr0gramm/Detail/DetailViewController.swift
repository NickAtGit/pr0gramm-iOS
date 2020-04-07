
import UIKit
import AVFoundation
import ScrollingContentViewController
import AVKit
import GTForceTouchGestureRecognizer

class DetailViewController: ScrollingContentViewController, StoryboardInitialViewController {

    weak var coordinator: Coordinator?

    private var stackView: UIStackView!
    private let imageView = TapableImageView()
    private let tagsCollectionViewController = TagsCollectionViewController.fromStoryboard()
    private let commentsStackView = UIStackView()
    private let infoView = InfoView.instantiateFromNib()
    private var avPlayer: AVPlayer?
    private var avPlayerViewController: TapableAVPlayerViewController?
    private let loadCommentsButton = UIButton()
    private var forceTouchGestureRecognizer: GTForceTouchGestureRecognizer!
    
    var item: Item? {
        didSet {
            guard let item = item else { return }
            coordinator?.pr0grammConnector.loadItemInfo(for: item.id) { self.itemInfo = $0; self.setupTags() }
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
                
        tagsCollectionViewController.coordinator = coordinator
        tagsCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(tagsCollectionViewController)
        
        loadCommentsButton.setTitle("Kommentare anzeigen", for: .normal)
        loadCommentsButton.addTarget(self, action: #selector(showComments), for: .touchUpInside)
        loadCommentsButton.isHidden = !AppSettings.isLoggedIn
        
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
        
//        avPlayerViewController.entersFullScreenWhenPlaybackBegins = true
        
//        forceTouchGestureRecognizer = GTForceTouchGestureRecognizer(target: self, action: #selector(upVote))
//        view.addGestureRecognizer(forceTouchGestureRecognizer)
    }
    
    @objc
    func upVote() {
        let navigationContoller = self.navigationController as! NavigationController
        if AppSettings.isLoggedIn {
            guard let id = item?.id else { return }
            coordinator?.pr0grammConnector.vote(itemId: "\(id)", value: 1)
            navigationContoller.showBanner(with: "Han blussert ⨁")
        } else {
            navigationContoller.showBanner(with: "Du musst eingeloggt sein, um dieses Feature zu nutzen")
        }
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
        guard (notificaiton.object as? TapableImageView) === imageView else { return }
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
        
        infoView.item = item
        infoView.pr0grammConnector = coordinator?.pr0grammConnector
        
        if let link = coordinator?.pr0grammConnector.imageLink(for: item) {
            imageView.downloadedFrom(link: link)
        } else {
            
            avPlayer = AVPlayer()
            avPlayerViewController = TapableAVPlayerViewController()
            avPlayerViewController?.delegate = self
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
            guard let link = coordinator?.pr0grammConnector.videoLink(for: item) else { return }
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
                commentView.pr0grammConnector = self.coordinator?.pr0grammConnector
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
    
    func cleanup() {
        avPlayer = nil
        avPlayerViewController = nil
        NotificationCenter.default.removeObserver(self)
//        forceTouchGestureRecognizer.removeTarget(self, action: nil)
//        view.removeGestureRecognizer(forceTouchGestureRecognizer)
//        forceTouchGestureRecognizer = nil
    }
}

extension DetailViewController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        playerViewController.player?.play()
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        playerViewController.player?.play()
    }
}
