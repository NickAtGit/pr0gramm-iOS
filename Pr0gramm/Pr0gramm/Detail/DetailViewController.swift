
import UIKit
import AVFoundation
import ScrollingContentViewController
import AVKit

class DetailViewController: ScrollingContentViewController, StoryboardInitialViewController {

    weak var coordinator: Coordinator?
    var viewModel: DetailViewModel! {
        didSet {
            infoView.viewModel = viewModel
            tagsCollectionViewController.viewModel = viewModel
        }
    }
    
    private var stackView: UIStackView!
    private let imageView = TapableImageView()
    private let tagsCollectionViewController = TagsCollectionViewController.fromStoryboard()
    private let commentsStackView = UIStackView()
    private let infoView = InfoView.instantiateFromNib()
    private var avPlayer: AVPlayer?
    private var avPlayerViewController: TapableAVPlayerViewController?
    private let loadCommentsButton = UIButton()
    private var commentsAreShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showImageDetail),
                                               name: Notification.Name("showImageDetail"),
                                               object: nil)
        
        scrollView.showsVerticalScrollIndicator = false
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .top
        
        commentsStackView.axis = .vertical
        commentsStackView.spacing = 25
                
        tagsCollectionViewController.coordinator = coordinator
        addChild(tagsCollectionViewController)
                
        stackView = UIStackView(arrangedSubviews: [imageView,
                                                   infoView,
                                                   tagsCollectionViewController.view,
                                                   commentsStackView])
        stackView.spacing = 40
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

        tagsCollectionViewController.didMove(toParent: self)

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
        
        let _ = viewModel.isTagsExpanded.observeNext(with: { [weak self] isExpanded in
            UIView.animate(withDuration: 0.25) {
                self?.view.layoutIfNeeded()
            }
        })
        
        let _ = viewModel.item.observeNext { [weak self] item in
            self?.updateUI(with: item)
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avPlayer?.pause()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
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
        
    private func updateUI(with item: Item) {

        avPlayer?.pause()
        imageView.heightAnchor.constraint(equalTo: view.widthAnchor,
                                          multiplier: CGFloat(item.height) / CGFloat(item.width)).isActive = true
        
        infoView.showCommentsAction = { [weak self] in
            guard let self = self else { return }
            self.coordinator?.showComments(viewModel: self.viewModel, from: self)
        }

        infoView.upvoteAction = { [weak self] in self?.navigation?.showBanner(with: "Han blussert") }
        infoView.downvoteAction = { [weak self] in self?.navigation?.showBanner(with: "Han miesert") }
        
        if let link = viewModel.imageLink() {
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
            guard let link = viewModel.videoLink() else { return }
            let url = URL(string: link)
            let playerItem = AVPlayerItem(url: url!)
            avPlayer.replaceCurrentItem(with: playerItem)
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

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        
        return HalfSizePresentationController(presentedViewController: presented,
                                              presenting: presenting)
    }
}

class HalfSizePresentationController : UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let containerView = containerView else {
                return CGRect.zero
            }

            return CGRect(x: 0,
                          y: containerView.bounds.height/2,
                          width: containerView.bounds.width,
                          height: containerView.bounds.height/2)
        }
    }
}
